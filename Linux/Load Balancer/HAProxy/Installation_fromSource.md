#Introduction#
This will be a short how-to on compiling the latest haproxy from source. This route will make sure you have the latest version of haproxy instead of relying on your package manager to keep you up to date (which is historically significantly behind).

#Downloading Source#
All we need to do is download the latest haproxy tarball from http://www.haproxy.org/#down
The current version as of this writing is 1.9

```
cd /usr/src
mkdir haproxy
cd haproxy
wget http://www.haproxy.org/download/1.5/src/haproxy-1.9.tar.gz
gunzip haproxy-1.9.tar.gz
tar -xvf haproxy-1.9.tar
```

#Compiling#
To compile haproxy from source, they require you specify `make` parameters. With this you can use pre-configured compile options or use a totally custom configuration. What fits my use-case is a prebuilt config plus a few extra custom parameters. You can learn about specific make targets at https://github.com/haproxy/haproxy
```
make TARGET=linux2628 USE_PCRE=1 USE_LIBCRYPT=1 USE_OPENSSL=yes USE_SYSTEMD=1
make install
```

#Creating systemd service#
```
vim /usr/lib/systemd/system/haproxy.service
#paste the following contents
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target

[Service]
ExecStart=ExecStart=/usr/local/sbin/haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -Ws
ExecReload=/bin/kill -USR2 $MAINPID

[Install]
WantedBy=multi-user.target



systemctl daemon-reload
systemctl enable haproxy.service
```

#Certificate Pinning#
If you want to use public certificate pinning to thwart MITM attacks, you'll first need to extract the base64 encoded version of your SPKI fingerprint. If your SSL Cert is already installed and working, run this command
```
openssl s_client -servername www.example.com -connect www.example.com:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```
where 'www.example.com' is replaced with your domain name. That output will produce a line that looks like this
```
writing RSA key
+EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw=
```
where +EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw= is the SPKI fingerprint (yours will be different). Now that you have obtained this, we will need to add this line to the HTTPS frontend of your haproxy config
```
rspadd Public-Key-Pins:\ pin-sha256="+EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw=";\ max-age=5184000;\ includeSubDomains
```

From here you'd follow the instructions in the other subfolders one level up for specific configurations and example configs.