### install openSSL if not installed already
```
yum install openssl
```


### make and go to nginx ssl work directory
```
mkdir -p /etc/ssl
cd /etc/ssl/
```


### create key and signing request
```
openssl genrsa -aes256 -out server.key 2048
openssl req -new -key server.key -out server.csr
```


### remove passphrase from key
```
cp server.key server.key.org
openssl rsa -in server.key.org -out server.key
```

### create DHE key
This takes a while
```
openssl dhparam -out dhparam.pem 4096
```


### IF USING VALID CERTIFICATE
### Submit your CSR to your CA
### Your CA will return a signed crt file
### append CA cert to your local crt
```
cat DigiCertCA.crt >> server.crt
```


### IF SELF SIGNING SSL CERT
```
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
```



#If using HAProxy for SSL
HAProxy requires certificates in the PEM format which is basically the ssl CRT file, any intermediate certs, and then the server key. The order is important. You're specifying a chain from the CA to your server's key. If using DigiCert, use the "apache" export model.
```
cat /etc/ssl/server.key /etc/ssl/SSLCert.crt /etc/ssl/CA.crt /etc/ssl/ItermediateCert.crt > /etc/ssl/ssl.pem
```



#If using NGINX for SSL
### Now in NGINX, create a vhost that uses SSL. These are the options
### I use for a hardened SSL install with forward secrecy.
### learn more about SSL hardening at ssllabs.com
```
server {
  listen   443;
      ssl    on;
      ssl_certificate    /etc/ssl/server.crt
      ssl_certificate_key    /etc/ssl/server.key;

      ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4";
      ssl_prefer_server_ciphers on;
      ssl_session_cache shared:SSL:10m;
      ssl_dhparam /etc/ssl/dhparam.pem;
      ssl_stapling on;
      ssl_stapling_verify on;
      add_header Strict-Transport-Security max-age=63072000;
      add_header X-Frame-Options DENY;
      add_header X-Content-Type-Options nosniff;

      ...other-config...
}
```


### If using LETSENCRYPT
This is for setting up letsencrypt SSL for multiple domains behind an HAProxy service. We will be setting this up to use webroot authentication and we will use HAProxy to forward all requests to %url%/.well-known/acme-challenge/ to a special Nginx vhost.

First let's make our HAProxy changes. For the HAProxy frontend that handles HTTP requests on port 80

```
acl isletsencrypt url_beg /.well-known/acme-challenge/
use_backend be_letsencrypt if isletsencrypt
```

Now we add the backend to HAProxy that will handle these requests. You will need to add your own webservers to the backend. Also notice that I've created a fictional http-hostname. This is so NGinx will have something to key off of when determining what vhost to use for the request.

```
backend be_letsencrypt
    mode http
    balance roundrobin
    option redispatch
    option forwardfor
    option http-server-close
    http-request set-header Host letsencryptwebroot.local.mm
    server web1 127.0.0.1:1080 check inter 4s weight 1 rise 3
```

Now let's setup the NGinx vhost file. The listen line, root line, and server_name line may differ from what your setup needs. Just need to make sure that the server_name matches the fictional hostname you specified in HAProxy.
```
server {
    listen 127.0.0.1:1080;
    server_name letsencryptwebroot.local.mm;
    root /var/www/letsencryptwebroot;
    index index.html;
}
```

Now let's run the letsencrypt command to generate the certificate. Specify all the domains using the -d parameter.

```
./letsencrypt-auto certonly -d subdomain0.domain.com -d subdomain1.domain.com --rsa-key-size 4096 --renew-by-default --agree-tos --webroot -w /var/www/letsencryptwebroot/
```

What happens next is yet to come. I've hit my SSL Request limit with letsencrypt during testing and I'll need to wait a week before I finish this documentation.

Keep in mind that HAProxy needs SSL certs in a special file. When I was initially testing letsencrypt with a single domain, it would generate ssl certs in /etc/letsencrypt/live/whatever.blah.com/

I would create the HAProxy cert via

```
cat /etc/letsencrypt/live/whatever.blah.com/privkey.pem /etc/letsencrypt/live/whatever.blah.com/cert.pem /etc/letsencrypt/live/whatever.blah.com/chain.pem > /etc/letsencrypt/live/whatever.blah.com/haproxy.pem
```

My HAProxy bind line for the HTTPS frontend looked like this

```
bind :443 ssl crt /etc/letsencrypt/live/whatever.blah.com/haproxy.pem ciphers ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4 no-sslv3
```