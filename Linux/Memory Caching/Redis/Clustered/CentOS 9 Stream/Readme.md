#Installation#
As of the time of this writing, redis multi-master clustering is unstable. Perform these steps on each redis node

```
cd ~
wget https://download.redis.io/redis-stable.tar.gz
gunzip redis-stable.tar.gz
tar -xvf redis-stable.tar
cd redis-stable
make BUILD_TLS=yes

yum install gcc

make install
```

#Create Service File#
```
vim /usr/lib/systemd/system/redis.service
```
> ####Paste the contents of configs/redis.service####

reload the systemd daemon and enable service
```
systemctl daemon-reload
systemctl enable redis.service
```

#Configuration#
```
echo '' > /etc/redis.conf
vim /etc/redis.conf
```
> ####Paste the contents of configs/redis.conf####

#Creating the Cluster#
We will assume we have 3 Redis servers for the cluster, which is the minimum recommended. Their IPs are 192.168.0.2-4

on .2 run this
```
/root/redis-3.0.0-rc3/src/redis-trib.rb create --replicas 0 192.168.0.2:6379 192.168.0.3:6379 192.168.0.4:6379
```

Let's say in the future you wish to add a fourth Redis server to the cluster with IP of .5. On any Redis node, preferable the one you created the cluster.
```
./redis-trib.rb add-node 192.168.0.5:7000
```

For more detailed information, please visit http://redis.io/topics/cluster-tutorial
