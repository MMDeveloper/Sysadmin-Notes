#Introduction#
If you prefer to run a master/slave setup instead of a multi-master environment, these are the steps you would follow. This can be done without taking down the existing/master db service or locking transactions. These instructions will assume you've already installed mariadb or mysql (these instructions work with both).

We will make the following assumptions:

 - You already have one DB server running either mysql or mariadb with IP 192.168.0.2
 - You have a new DB server running the same DB engine with IP 192.168.0.3

I don't know if you can run replication between different engines (one mariadb and one mysql), I have never tried it and I would never try it.

#Master Server#
On the master you'll need to edit the mysql/mariadb config file and add these parameters to the mysqld section. The server-id parameter must be unique for each server in the replication relationship, typically just an incrementing number
```
vim /etc/my.cnf
```
> ###Paste the contents of configs/master-my.cnf####

Now restart the db service

#Secure the Install#
You only need to perform this once, but you should run this. It will allow you to remove anonymous access, the test database, and set a root password
```
/usr/bin/mysql_secure_installation
```

Access the db service from the command line on the master server.
```
mysql -h localhost -u root -p
```
we need to create a user to be used for the replication procedur. This will create a user account named 'repl_user' to be used by the slave server only
```sql
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'192.168.0.3' IDENTIFIED BY 'q2w3e4r5t6y7u8i9o0p';
exit
```

Now we need to take a live backup of the databases on the master with special parameters
```
mysqldump -h localhost -u root -p --all-databases --flush-privileges --single-transaction --master-data=2 --flush-logs --triggers --routines --events --hex-blob >master.sql
```

Now copy this backup file to the slave server using whatever method you prefer
Now go back into the mysql/mariadb command line and run this
```sql
SHOW MASTER STATUS\G
```

Take note of the file and position, we'll assume the answers were
 - File: mysql-bin.000413
 - Position: 328

#Slave Server#
First we need to configure the db service, take note the server-id is different
```
vim /etc/my.cnf
```
> ###Paste the contents of configs/slave-my.cnf####

Restart the DB service on the slave. Now we need to import the backup you copied from the master
```
mysql -u root -p < master.sql
```

Now access the db service on the slave from the command line and configure the slave. Use the file and position parameters from the master server status query and run this query, substituting the values with your own
```sql
CHANGE MASTER TO
    MASTER_HOST='192.168.0.2',
    MASTER_PORT=3306,
    MASTER_USER='repl_user',
    MASTER_PASSWORD='q2w3e4r5t6y7u8i9o0p',
    MASTER_LOG_FILE='mysql-bin.000413',
    MASTER_LOG_POS=328;

START SLAVE;
SHOW SLAVE STATUS\G
```

You should see the following successful messages
```Slave_IO_State: Waiting for master to send event
Slave_IO_Running: Yes
Slave_SQL_Running: Yes
Last_SQL_Error: <blank>
```

Now, re-edit the db service config file
```
vim /etc/my.cnf
```
Remove this one line from the config
```
skip-slave-start
```

Save the file, no restart needed. done
