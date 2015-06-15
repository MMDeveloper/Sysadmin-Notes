#Installation#
See Installing the Epel/Remi repositories
```
cd ~
mkdir temp
cd temp
wget -l 1 -nd -nc -r -A.rpm http://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/epel-7Server/x86_64/

yum install glusterfs-3.6.2-1.el7.x86_64.rpm glusterfs-api-3.6.2-1.el7.x86_64.rpm glusterfs-cli-3.6.2-1.el7.x86_64.rpm glusterfs-fuse-3.6.2-1.el7.x86_64.rpm glusterfs-geo-replication-3.6.2-1.el7.x86_64.rpm glusterfs-libs-3.6.2-1.el7.x86_64.rpm glusterfs-server-3.6.2-1.el7.x86_64.rpm

systemctl enable glusterd
systemctl enable glusterfsd
systemctl restart glusterd
systemctl restart glusterfsd
```

#Create Storage Cluster#
What we're going to setup is called a Replicated Gluster Cluster. This acts just like microsoft's DFS replication. If each storage node only has a 10gb drive to offer to the cluster, the storage pool is only 10gb (not the sum of all storage pool drives because each server will have a copy of each file, this provides fault tolerance). There are other ways to setup a Gluster Cluster but I won't cover that here, you can google it.

On the web1 server, run the following command
```
gluster peer probe 192.168.1.2
```

Confirm the gluster service sees the other gluster node now
```
gluster peer status
```

On each GlusterFS Node, we're going to mount the block device to be used as the storage disk for that node.
```
fdisk /dev/xvdb ### make a single primary partition spanning entire disk
mkfs.ext4 /dev/xvdb1
mkdir -p /export/xvdb1 && mount /dev/xvdb1 /export/xvdb1 && mkdir -p /export/xvdb1/brick
echo "/dev/xvdb1 /export/xvdb1 ext4 defaults 0 0"  >> /etc/fstab
```

Back to web1, run this to create the gluster volume
```
gluster volume create gv0 replica 2 192.168.1.1:/export/xvdb1/brick 192.168.1.2:/export/xvdb1/brick
gluster volume start gv0
```

#Mount GlusterFS On Client#
Using the native GlustFS Client is recommended for environments needing high write performance. For environments needing high read performance, especially with small files, it is recommended to mount the GlusterFS volumes via NFS.
```
yum install glusterfs-client
vim /etc/fstab
```

add the following entry on web1
```
192.168.1.1:/gv0 /var/www/external glusterfs defaults,_netdev,backupvolfile-server=192.168.1.2 0 0
```

add the following entry on web2's fstab
```
192.168.1.2:/gv0 /var/www/external glusterfs defaults,_netdev,backupvolfile-server=192.168.1.1 0 0
```

By doing this, each webserver is acting as a node in the clustered storage, and also mounting 'itself' as a client so even though the files are technically a network share, they're still locally accessible instead of remotely-via-network.