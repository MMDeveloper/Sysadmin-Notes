#Installation of HAProxy#
```
yum install haproxy
systemctl enable haproxy.service
```
#Configuration of HAProxy#
HAProxy configuration is very instance-specific so I can't really give you a copy/paste config file as your needs may differ. I have however provided a config file I created for an actual environment. Has stats, multiple frontends and backends, even a ratelimit.
```
vim /etc/haproxy/haproxy.conf
```
> ####sample config in configs/sample-haproxy.conf####
