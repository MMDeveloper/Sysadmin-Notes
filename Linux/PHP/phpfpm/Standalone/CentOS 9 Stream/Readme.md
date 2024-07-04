```
yum install php php-php-fpm php-php-common php-php-pear php-php-pdo php-php-pgsql php-php-opcache php-php-gd php-php-mbstring php-php-mcrypt php-php-xml php-php-mysqlnd
systemctl enable php-php-fpm.service
```

#Configuration#
```
vim /etc/php.ini
```
> ####update the php.ini file with the contents below####

```
disable_functions = _getppid, apache_child_terminate, apache_setenv, define_syslog_variables, diskfreespace, dl, escapeshellarg, escapeshellcmd, eval, fp, fpaththru, fput, ftp_connect, ftp_exec, ftp_get, ftp_login, ftp_nb_fput, ftp_put, ftp_raw, ftp_rawlist, highlight_file, ignore_user_abord, ini_alter, ini_get_all, ini_restore, inject_code, leak, link, listen, mysql_pconnect, openlog, passthru, pcntl_exec, phpAds_XmlRpc, phpAds_remoteInfo, phpAds_xmlrpcDecode, phpAds_xmlrpcEncode, php_uname, popen, posix, posix_ctermid, posix_getcwd, posix_getegid, posix_geteuid, posix_getgid, posix_getgrgid, posix_getgrnam, posix_getgroups, posix_getlogin, posix_getpgid, posix_getpgrp, posix_getpid, posix_getpwnam, posix_getpwuid, posix_getrlimit, posix_getsid, posix_getuid, posix_isatty, posix_kill, posix_mkfifo, posix_setegid, posix_seteuid, posix_setgid, posix_setpgid, posix_setsid, posix_setuid, posix_times, posix_ttyname, posix_uname, proc_close, proc_get_status, proc_nice, proc_open, proc_terminate, set_time_limit, shell_exec, show_source, socket_accept, socket_bind, socket_clear_error, socket_close, socket_connect source, syslog, system, tmpfile, virtual, xmlrpc_entity_decode
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE
date.timezone = America/New_York
```

```
vim /etc/php-fpm.d/www.conf
```
> ####update the www.conf file with the contents below####

 - comment out the 'listen' lines near the top
 - add these three lines
```
listen = /var/run/php-fpm-0.sock
listen.owner = nginx
listen.group = nginx
```

Make the following additional changes
```
pm = static
;You will need to adjust this paramater to meet your needs
pm.max_children = 10
```

Now rename and make a copy of the www.conf file and change the sock name
```
mv /etc/php-fpm.d/www.conf /etc/php-fpm.d/www-0.conf
cp /etc/php-fpm.d/www-0.conf /etc/php-fpm.d/www-1.conf
vi /etc/php-fpm.d/www-1.conf
```

Change `listen = /var/run/php-fpm-0.sock` to `listen = /var/run/php-fpm-1.sock`