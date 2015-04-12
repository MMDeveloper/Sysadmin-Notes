#Installation#
See Installing the Epel/Remi repositories
```
yum install redis
```

#Configuration#
```
vim /etc/redis.conf
```
Update existing values

```
### You'll want to rename the CONFIG command to something random for security reasons
rename-command CONFIG 30abfb3034b01b5ffccbb3d46630f14953d9967f94dde5

### You might want to bind redis to a unix socket rather than a TCP socket
#bind 127.0.0.1
unixsocket /tmp/redis.sock
unixsocketperm 777

### Or you might want to bind to a TCP socket
#bind 127.0.0.1
#unixsocket /tmp/redis.sock
#unixsocketperm 777

### You might want to require a password to connect to the redis instance
requirepass supersecretpassword
```
