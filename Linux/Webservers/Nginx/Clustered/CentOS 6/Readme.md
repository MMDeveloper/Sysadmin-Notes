#Installation#
See Installing the Epel/Remi repositories
```
yum install nginx
chkconfig --add nginx
chkconfig --level 345 nginx on
```

#Configuration#
I will not provide any vhost configs as they greatly differ between the needs of different websites, however I will offer my goto nginx.conf file. Please read the comments in the config file so you can make it fit your environment
```
vim /var/www/internal/conf/nginx/nginx.conf
```
> ####Paste the contents of configs/nginx.conf####

```
cd /etc/nginx/
rm -f nginx.conf
ln -s /var/www/internal/conf/nginx/nginx.conf ./
```