#Installation#
See Installing the Epel/Remi repositories
```
yum install nginx
systemctl enable nginx.service
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

#Firewall#
First we need to determine which zones are active
```
firewall-cmd --get-active-zones
```
In my dev environment, I only have one zone called `internal` active. Now we open the web ports for the target zone
```
firewall-cmd --zone=internal --add-port=80/tcp --permanent
firewall-cmd --zone=internal --add-port=443/tcp --permanent
```