#Installation#
See Installing the Epel/Remi repositories

```
yum install php72 php72-php-fpm php72-php-common php72-php-pear php72-php-pdo php72-php-pgsql php72-php-opcache php72-php-gd php72-php-mbstring php72-php-mcrypt php72-php-xml php72-php-mysqlnd
systemctl enable php72-php-fpm.service
```

#Configuration#
```
vim /etc/opt/remi/php72/php.ini
```
> ####update the php.ini file with the contents below####

```
disable_functions = _getppid, apache_child_terminate, apache_setenv, define_syslog_variables, diskfreespace, dl, escapeshellarg, escapeshellcmd, eval, fp, fpaththru, fput, ftp_connect, ftp_exec, ftp_get, ftp_login, ftp_nb_fput, ftp_put, ftp_raw, ftp_rawlist, highlight_file, ignore_user_abord, ini_alter, ini_get_all, ini_restore, inject_code, leak, link, listen, mysql_pconnect, openlog, passthru, pcntl_exec, phpAds_XmlRpc, phpAds_remoteInfo, phpAds_xmlrpcDecode, phpAds_xmlrpcEncode, php_uname, popen, posix, posix_ctermid, posix_getcwd, posix_getegid, posix_geteuid, posix_getgid, posix_getgrgid, posix_getgrnam, posix_getgroups, posix_getlogin, posix_getpgid, posix_getpgrp, posix_getpid, posix_getpwnam, posix_getpwuid, posix_getrlimit, posix_getsid, posix_getuid, posix_isatty, posix_kill, posix_mkfifo, posix_setegid, posix_seteuid, posix_setgid, posix_setpgid, posix_setsid, posix_setuid, posix_times, posix_ttyname, posix_uname, proc_close, proc_get_status, proc_nice, proc_open, proc_terminate, set_time_limit, shell_exec, show_source, socket_accept, socket_bind, socket_clear_error, socket_close, socket_connect source, syslog, system, tmpfile, virtual, xmlrpc_entity_decode
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE
date.timezone = America/New_York
```

```
vim /etc/opt/remi/php72/php-fpm.d/www.conf
```
> ####update the php-fpm.conf file with the contents below####

include=/var/www/internal/conf/php-fpm/pools

Now we'll move the config files to the clustered locations for synchronization
```
mv /etc/opt/remi/php72/php.ini /var/www/internal/conf/php-fpm/
ln -s /var/www/internal/conf/php-fpm/php.ini /etc/opt/remi/php72/
cp /etc/opt/remi/php72/php-fpm.d/www.conf /var/www/internal/conf/php-fpm/pools/www0.conf
vim /var/www/internal/conf/php-fpm/pools/www0.conf
```
> ####update the www0.conf file with the contents below####

 - change [www] to [www0]
 - comment out the 'listen' lines near the top
 - add these three lines
````
listen = /var/run/php72-fpm-0.sock
listen.owner = nginx
listen.group = nginx
```