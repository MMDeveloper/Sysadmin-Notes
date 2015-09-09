#Installation of HAProxy on CentOS 6#
```
yum install haproxy
chkconfig --add haproxy
chkconfig --level 345 haproxy on
```

#Installation of HAProxy on CentOS 7#
```
yum install haproxy
systemctl enable haproxy.service
```