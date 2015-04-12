#Introduction#
For this setup, we will be using HAProxy and Keepalived for a cluster of load balancers. Each of the below steps will be performed on each HAProxy/Keepalived server, typically the only configuration differences are node-ids and which order nodes should fail-over.

#Installation of HAProxy#
```
yum install haproxy
chkconfig --add haproxy
chkconfig --level 345 haproxy on
```

#Installation of Keepalived#
```
yum install keepalived
chkconfig --add keepalived
chkconfig --level 345 keepalived on
```

#Configuration of HAProxy#
HAProxy configuration is very instance-specific so I can't really give you a copy/paste config file as your needs may differ. I have however provided a config file I created for an actual environment. Has stats, multiple frontends and backends, even a ratelimit.
```
vim /etc/haproxy/haproxy.conf
```
> ####sample config in configs/sample-haproxy.conf####

#Configuration of keealived#
```
vim /etc/keepalived/keepalived.conf
```
> ###Paste the contents of configs/keepalived-master.conf if this is the first keepalived node####
> ###Paste the contents of configs/keepalived-backup.conf if this is a backup keepalived node####
Please make sure to read the comments in the config files to update the appropriate values

Restart the services after configuration changes
```
service haproxy restart
service keepalived restart
```
