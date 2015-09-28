#Introduction#
They have a repository configuration tool located at https://downloads.mariadb.org/mariadb/repositories/#mirror=nethub

I will assume CentOS 6 64bit and MariaDB+Galera v10.
```
vim /etc/yum.repos.d/MariaDB.repo
```

> ####Paste the contents of configs/MariaDB.repo####

####Update YUM####
```
yum update
```
#Installation#
```
yum install MariaDB-client MariaDB-Galera-server galera
systemctl enable mariadb.service
```
#Configuration#
```
vim /etc/my.cnf.d/server.cnf
```

> ####Paste the contents of configs/server.cnf####

####start this DB service####
```
systemctl start mariadb.service
```

#Firewall#
First we need to determine which zones are active
```
firewall-cmd --get-active-zones
```
In my dev environment, I only have one zone called `internal` active. Now we open the DB port for the target zone
```
firewall-cmd --zone=internal --add-port=3306/tcp --permanent
```