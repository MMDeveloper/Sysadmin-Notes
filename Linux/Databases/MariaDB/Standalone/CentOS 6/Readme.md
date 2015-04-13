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
chkconfig --add mysql
chkconfig --level 345 mysql on
service mysql stop
```
#Configuration#
```
vim /etc/my.cnf.d/server.cnf
```

> ####Paste the contents of configs/server.cnf####

####start this DB service####
```
service mysql start
```