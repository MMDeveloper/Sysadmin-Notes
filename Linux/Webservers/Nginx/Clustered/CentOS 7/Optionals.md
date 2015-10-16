#GeoIP#
If you want to filter requests based on geographical location, you need to have the GeoIP module compiled into Nginx. To check for this, run:
```
nginx -V
```

Search for "--with-http_geoip_module". You can also run this and see if you get anything back at all.
```
nginx -V | grep -i geoip
```

If you have GeoIP compiled into Nginx, integration is easy.
```
cd /var/www/internal/conf/nginx/
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz
```

Now we need to edit the main nginx config file
```
vim /var/www/internal/conf/nginx/nginx.conf
```

add this line at the top of the http{} block before anything else
```
geoip_country /var/www/internal/conf/nginx/GeoIP.dat;
```

Done.. Now, if you wanted to disallow all countries except USA, you'd add this just after the previous line. You can look up geoip country codes at http://dev.maxmind.com/geoip/legacy/codes/iso3166/
```
map $geoip_country_code $allowed_country {
    default no;
    US yes;
}
```

In your vhost definitions, any site you wanted to apply this restriction
```
if ($allowed_country = no) {
    return 403;
}
```

#Ioncube#
Download the ioncube.tar.gz of loaders from their website https://www.ioncube.com/loaders.php
```
copy ioncube.tar.gz to /var/www/internal/
gunzip ioncube.tar.gz
tar -xvf ioncube.tar
rm -f ioncube.tar
```

From here I would remove any loaders in the ioncube directory except the one for the php version you're running, just to save space
```
cd ioncube
rm -f ioncube_loader_lin_4*
rm -f ioncube_loader_lin_5.[0,1,2,3,4,5]*
rm ioncube_loader_lin_5.6_ts.so
```

Now we need to tell PHP to load the ioncube module
```
vim /var/www/internal/conf/php-fpm/php.ini
zend_extension=/var/www/internal/ioncube/ioncube_loader_lin_5.6.so
```

Note, if you have the Zend encoder already installed, make sure that the ioncube extension appears BEFORE the zend extension in the php.ini file. If the zend encoder is loaded first, ioncube will not function correctly. I have no run into this but I've seen this in their support forums.

#LDAPS Authentication#
See Installing the Epel/Remi repositories

If you plan on making LDAPS calls, you'll need to make your webserver trust the CA certificate. Two ways to accomplish this. The easiest way is to make the webserver trust any CA, the other way is to export the CA cert and import it into openSSL on each webserver. I typically just have openSSL trust all CA certificates. Note that this does NOT affect web browsing and for this entire configuration, only applies to LDAPS traffic.

make sure the dependencies are installed
```
yum install openssl php70-php-ldap openldap
vim /etc/openldap/ldap.conf
```

add this line
```
TLS_REQCERT     never
```
