#Installation#
See Installing the Epel/Remi repositories
```
yum install nginx
systemctl enable nginx.service
```

#Configuration#
I will not provide any vhost configs as they greatly differ between the needs of different websites, however I will offer my goto nginx.conf file. Please read the comments in the config file so you can make it fit your environment
```
vim /etc/nginx/nginx.conf
```
> ####Paste the contents of configs/nginx.conf####