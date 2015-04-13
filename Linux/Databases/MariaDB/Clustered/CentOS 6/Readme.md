#Introduction#
The easiest way I've found to setup the multi-master datatabase pool is using MariaDB+Galera. They have a repository configuration tool located at https://downloads.mariadb.org/mariadb/repositories/#mirror=nethub

The following instructions should be executed on every DB server to be put in the cluster. I will assume CentOS 6 64bit and MariaDB+Galera v10.
```
vim /etc/yum.repos.d/MariaDB.repo
```

> ####Paste the contents of configs/MariaDB.repo####

####Update YUM####
```
yum update
```
#Installation#
```
yum install MariaDB-client MariaDB-Galera-server galera
chkconfig --add mysql
chkconfig --level 345 mysql on
service mysql stop
```
#Configuration#
```
vim /etc/my.cnf.d/server.cnf
```

> ####Paste the contents of configs/server.cnf####

> ###Do not start the DB service yet###


#IF THIS IS THE FIRST NODE OF A NEW CLUSTER#
When building a new cluster, you need at least 2 DB servers ready to go, minimum recommended is three to avoid split-brain syndrom. When building the cluster, one DB server should be dedicated as the master. It will only be the master until the second DB server connects, at which point the concept of 'master' disappears. Basically the first one needs to be started with a special startup parameter that kind of advertises that this is a new cluster and for the next one to join, to copy everything from it.

 - Set the cluster name parameter to something unique
 - Set the node name to the servers hostname, must be unique
 - The wsrep_cluster_address should be gcomm://

####Now, start the 'master' DB server####
```
service mysql bootstrap
```
The cluster is waiting for a second server to join. Now go to your next DB server and follow the 'adding a node' instructions. Once you've added a second node, stop the DB service on this host. Update the server.cnf file and change the gcomm:// parameter to a comma delimited list of ALL IP addresses of all nodes except THIS server. Stop and start the DB service on this host and it will 'join the cluster'. It may or may not do an SST Transfer, depending if data changed on the other nodes while you were doing this.

#Adding a node to an existing cluster#
The only config-differences between the first node and an existing node is the cluster address, the node address, and the node name. The cluster address parameter tells the DB server all of the IPs to try and connect to; to try and pull the cluster configuration and sync its databases, otherwise fail. The node address is simply the servers IP address. The node name is a unique ID for that node in that cluster, typically the server hostname The cluster address now should be a comma delimited address of the IPs (or DNS records) of all the other DB servers in the cluster. For example, if I have a 3 server pool (192.168.3.1-3) and wish to add a .4 server, the two parameters would look like this:

 - wsrep_cluster_address=gcomm://192.168.3.1,192.168.3.2,192.168.3.3
 - wsrep_node_address='192.168.3.4'
 - wsrep_node_name='DB4'

The cluster address should be a list of all node IPs except the IP of this server

####start this DB service####
```
service mysql start
```

You should see it start the DB process and do what's called an SST Transfer. This means it has joined the cluster and is syncing the databases. Once the sync is complete, you will get your command prompt back.

#Maintaining the Cluster#
With this type of cluster, you can reboot DB servers at will and no data loss will occur. The load balancer has a MySQL user that it uses to check the server is up. As soon as it senses the server is going down it immediately removes it from the pool until it's back up.

You can run updates on each server and reboot them at will. You can even stop the DB service, whack the entire /var/lib/mysql data directory and restart the DB service and it will rebuild it from the cluster (learned this while trying to break it). The easiest way to monitor the health of the cluster is by checking the cluster size. You can do this by running the following query on ANY of the DB servers in the cluster:

```sql
show status like 'wsrep%';
```

#Secure the Install#
In a replicated environment, you only need to perform this on one node, but you should run this. It will allow you to remove anonymous access, the test database, and set a root password
```
/usr/bin/mysql_secure_installation
```

near the bottom of the results will be a record called something like "wsrep_clustersize" and it should be the number of servers actively in your DB cluster.

Any DB updates (including users, etc) are immediately replicated to other DB servers in the cluster. There are some known gotchas you should read about though. https://mariadb.com/kb/en/mariadb/mariadb-galera-cluster-known-limitations/

#Rebooting the Cluster#
You can reboot cluster nodes as often as you like, whenever you like. The only "thing" is that at least ONE node must remain up to keep the cluster alive. If at ANY point ALL cluster nodes go down. You will need to bootstrap a new cluster following the "Building the Cluster" instructions.. FEAR NOT YOUR DATA IS NOT GONE.

Just pick a server, change the gcomm address, bootstrap the new cluster, restart the DB service on any of the other nodes, revert the gcomm address on the first node and cycle the DB service there. Cycle the DB service on all the other nodes and they will also auto-rejoin the cluster and sync.