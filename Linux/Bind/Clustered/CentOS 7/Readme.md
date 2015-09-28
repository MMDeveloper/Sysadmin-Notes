#Installation#
```
yum install bind bind-utils bind-chroot
systemctl enable bind.service
cd /var/named/chroot/
mv /var/named/
```
#Configuration#
move data files to chroot directory
```
find /var/named/ -mindepth 1 -maxdepth 1 -not -iname "chroot" -exec mv {} /var/named/chroot{} \;
mv /etc/named* /var/named/chroot/etc/
ln -sf /var/named/chroot/etc/named.conf /etc/named.conf
```

reset permissions
```
chown -R named:named /var/named/chroot/var/named/
chown -R named:named /var/named/chroot/etc/
```

#Firewall#
First we need to determine which zones are active
```
firewall-cmd --get-active-zones
```
In my dev environment, I only have one zone called `internal` active. Now we open the DNS ports for the target zone
```
firewall-cmd --zone=internal --add-port=53/tcp --permanent
firewall-cmd --zone=internal --add-port=53/udp --permanent
```

#Partitioning#
Whether or not you're going to be using your BIND service for both Internal and External DNS, it's good practice to go ahead and partition it for that, it's very easy. For partitioning, you'll create an ACL with your internal addresses (plus localhost). You wrap your zone files within "views", an internal view and an external view. The different views use your ACL to determine which zone files to read from for a DNS query response based on the client's IP address. You can review the sample config from my own DNS server to see it in action.

#DNS Slaves#
The master DNS server must have "type" of "master" for all non-stock zones it's serving. In the example config the two views utilize a parameter called "allow-transfer" which can either be a list of IP addresses or ACLs that specify all of your BIND slave servers. There are two ways to setup BIND slave servers, either via push updates (preferred method) or by polling. Push updates are immediate updates on slave servers while polling involves each slave server polling the master for updates on a schedule (which obviously causes unecessary BIND communication and lagged DNS updates). I will go over setting up PUSH updates.

Once you follow the Install instructions for BIND on your BIND slave server(s), copy the named.conf file from the master onto each slave. The reason for this, BIND replication will not transfer new zones, only updates to zones. Each slave server must already have knowledge of DNS zones for it to process pushed updates for them.

Once you've copied the named.conf file to the slaves, for each slave, you must make the following modifications:

 - for each zone, change the "type" from "master" to "slave".
 - for each slave zone, add a new parameter: masters { 10.0.0.7; }; #where 10.0.0.7 is the IP address of the BIND master server

#Integration with DHCP#
If you have DHCPD running on a linux box and wish to push DDNS to your BIND server, there is a little bit more config to do. This should be done on your MASTER server only. First you should refer to DHCP's configuration folder on how to do the first half of the configuration
```
vim /var/named/chroot/etc/named.conf
```
Paste this line near the top, outside of any declaration block
```
include "/var/named/chroot/etc/rndc.key";
```
Now for each zone that will receive DDNS updates from Bind, put this as their allow-update setting
```
allow-update { key rndc-key; };
```
Now cycle both BIND and DHCP and you should be good to go.