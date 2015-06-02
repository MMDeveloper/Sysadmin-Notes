#Installation#
See Installing the Epel/Remi repositories

```
yum install php56 php56-php-fpm php56-php-common php56-php-pear php56-php-pdo php56-php-pgsql php56-php-pecl-memcache php56-php-opcache php56-php-gd php56-php-mbstring php56-php-mcrypt php56-php-xml php56-php-mysqlnd
systemctl enable php56-php-fpm.service
```

#Configuration#
```
vim /opt/remi/php56/root/etc/php.ini
```
> ####update the php.ini file with the contents below####

```
disable_functions = _getppid, apache_child_terminate, apache_setenv, define_syslog_variables, diskfreespace, dl, escapeshellarg, escapeshellcmd, eval, fp, fpaththru, fput, ftp_connect, ftp_exec, ftp_get, ftp_login, ftp_nb_fput, ftp_put, ftp_raw, ftp_rawlist, highlight_file, ignore_user_abord, ini_alter, ini_get_all, ini_restore, inject_code, leak, link, listen, mysql_pconnect, openlog, passthru, pcntl_exec, phpAds_XmlRpc, phpAds_remoteInfo, phpAds_xmlrpcDecode, phpAds_xmlrpcEncode, php_uname, popen, posix, posix_ctermid, posix_getcwd, posix_getegid, posix_geteuid, posix_getgid, posix_getgrgid, posix_getgrnam, posix_getgroups, posix_getlogin, posix_getpgid, posix_getpgrp, posix_getpid, posix_getpwnam, posix_getpwuid, posix_getrlimit, posix_getsid, posix_getuid, posix_isatty, posix_kill, posix_mkfifo, posix_setegid, posix_seteuid, posix_setgid, posix_setpgid, posix_setsid, posix_setuid, posix_times, posix_ttyname, posix_uname, proc_close, proc_get_status, proc_nice, proc_open, proc_terminate, set_time_limit, shell_exec, show_source, socket_accept, socket_bind, socket_clear_error, socket_close, socket_connect source, syslog, system, tmpfile, virtual, xmlrpc_entity_decode
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE
date.timezone = America/New_York
```

```
vim /opt/remi/php56/root/etc/php-fpm.conf
```
> ####update the php-fpm.conf file with the contents below####

include=/var/www/internal/conf/php-fpm/pools

Now we'll move the config files to the clustered locations for synchronization
```
mv /opt/remi/php56/root/etc/php.ini /var/www/internal/conf/php-fpm/
ln -s /var/www/internal/conf/php-fpm/php.ini /opt/remi/php56/root/etc/
cp /opt/remi/php56/root/etc/php-fpm.d/www.conf /var/www/internal/conf/php-fpm/pools/www0.conf
vim /var/www/internal/conf/php-fpm/pools/www0.conf
```
> ####update the www0.conf file with the contents below####

 - change [www] to [www0]
 - comment out the 'listen' lines near the top
 - add these three lines
````
listen = /var/run/php56-fpm-0.sock
listen.owner = nginx
listen.group = nginx
```