#Introduction#
For an HA setup and true load balancing, I personally prefer to deploy HAProxy. Load balancing requests for HA does no
good with a single HAProxy server as that provides a single point of failure. It is recommended to have at least 2, using
keepalived to setup your HAProxy servers in an active/standby cluster via a heartbeat. These instructions will work for load
balancing any service, I'm just using HAProxy as an example

To achieve this you'll need N+1 IP addresses, one for each HAProxy server and one 'Floating IP' that is passed around.
This "Floating IP" is the IP address that should be used to communicate with the "current active node"; it is the internal IP that should be NAT'd to the outside world.

For the following documents, I will make the following assumptions:

* You will have two HAProxy servers
* HAProxy0
** Static IP: 192.168.0.3
* HAProxy1
** Static IP: 192.168.0.4
* Floating IP: 192.168.0.2

For this setup, we will be using HAProxy and Keepalived for a cluster of load balancers. Each of the below steps will be
performed on each HAProxy/Keepalived server, typically the only configuration differences are node-ids and which order nodes
should fail-over. You'll need to install keepalived on each node.

#Configuration of keealived#
```
vim /etc/keepalived/keepalived.conf
```
> ###Paste the contents of configs/keepalived-master.conf if this is the primary keepalived node####
> ###Paste the contents of configs/keepalived-backup.conf if this is a backup keepalived node####
Please make sure to read the comments in the config files to update the appropriate values

Restart the HAProxy service and Keepalived service after configuration changes