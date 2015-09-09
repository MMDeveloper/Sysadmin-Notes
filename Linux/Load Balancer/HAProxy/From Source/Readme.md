#Introduction#
This will be a short how-to on compiling the latest haproxy from source. This route will make sure you have the latest version of haproxy instead of relying on your package manager to keep you up to date (which is historically significantly behind).

#Downloading Source#
All we need to do is download the latest haproxy tarball from http://www.haproxy.org/#down
The current version as of this writing is 1.5.14

```
cd /usr/src
mkdir haproxy
cd haproxy
wget http://www.haproxy.org/download/1.5/src/haproxy-1.5.14.tar.gz
gunzip haproxy-1.5.14.tar.gz
tar -xvf haproxy-1.5.14.tar
```

#Compiling#
To compile haproxy from source, they require you specify `make` parameters. With this you can use pre-configured compile options or use a totally custom configuration. What fits my use-case is a prebuilt config plus a few extra custom parameters. You can learn about specific make targets at https://github.com/haproxy/haproxy
```
make TARGET=linux2628 USE_PCRE=1 USE_LIBCRYPT=1 USE_OPENSSL=yes
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
ExecStart=/usr/local/sbin/haproxy-systemd-wrapper -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid
ExecReload=/bin/kill -USR2 $MAINPID

[Install]
WantedBy=multi-user.target



systemctl daemon-reload
systemctl enable haproxy.service
```

From here you'd follow the instructions in the other subfolders one level up for specific configurations and example configs.