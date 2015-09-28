#Introduction#
I wanted to experiment with the nginx TRIM module, but it did not come with the epel version of nginx. I needed to compile from source. Below are my experiences to make this happen.

#Downloading Source#
First thing I needed to do was download the latest stable tarball of nginx, the latest stable tarball of the Trim module, and the latest stable tarball of the MaxMind GeoIP database (as I use the GeoIP functionality).

Download the latest nginx tarball from: http://nginx.org/en/download.html
The latest Trim module tarball from: http://wiki.nginx.org/HttpStripModule
The latest GeoIP Database tarball from: http://geolite.maxmind.com/download/geoip/api/c/GeoIP.tar.gz
```
cd /usr/src/
mkdir nginx && cd nginx
wget url://to/nginx/nginx.tar.gz
gunzip nginx.tar.gz
tar -xvf nginx.tar
rm nginx.tar
cd nginx-1.9.4 #or whatever the subfolder is called
mkdir modules && cd modules
wget url://to/trim-module.tar.gz
wget url://to/maxmind/geoip.tar.gz
gunzip trim-module.tar.gz
gunzip geoip.tar.gz
tar -xvf trim-module.tar
tar -xvf geoip.tar
rm trim-module.tar geoip.tar
```

We should now have a directory of /usr/src/nginx/nginx-1.9.4/, and inside that folder is a modules folder with 2 directories (trim and geoip). First thing is first, we need to install GeoIP.
#Compiling#
```
cd GeoIP
./configure --prefix=/usr/local
make
make install
vim /usr/local/etc/GeoIP.conf

#enter the following lines
LicenseKey 000000000000
UserId 999999
ProductIds 506 533
```

Now we need to configure and compile nginx
```
./configure \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \
    --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
    --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \
    --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \
    --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --user=nginx --group=nginx \
    --with-file-aio \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_spdy_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_geoip_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_stub_status_module \
    --with-http_perl_module \
    --with-mail --with-mail_ssl_module \
    --with-pcre --with-pcre-jit \
    --with-debug \
    --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' \
    --with-ld-opt='-Wl,-R,/usr/local/lib -L /usr/local/lib,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E' \
    --add-module=/usr/src/nginx/nginx-1.9.4/modules/mod_strip

#Take note of the last line, the --add-module should point to the path of the mod_strip folder (in the modules folder we created).
make
make install
```

#Creating systemd service#
```
vim /usr/lib/systemd/system/nginx.service
#paste the following contents
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=process
KillSignal=SIGQUIT
TimeoutStopSec=5
PrivateTmp=true

[Install]
WantedBy=multi-user.target



systemctl daemon-reload
systemctl enable nginx.service
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