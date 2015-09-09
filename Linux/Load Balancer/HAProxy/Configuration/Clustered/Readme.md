#Introduction#
For an HA setup and true load balancing, I personally prefer to deploy HAProxy. Load balancing requests for HA does no good with a single HAProxy server as that provides a single point of failure. It is recommended to have at least 2, using keepalived to setup your HAProxy servers in an active/standby cluster via a heartbeat.

To achieve this you'll need N+1 IP addresses, one for each HAProxy server and one 'Floating IP' that is passed around. This "Floating IP" is the IP address that should be used to send traffic to your cluster/farm of servers; it is the internal IP that should be NAT'd to the outside world.

For the following documents, I will make the following assumptions:

* You will have two HAProxy servers
* HAProxy0
** Heartbeat IP: 192.168.0.3
* HAProxy1
** Heartbeat IP: 192.168.0.4
* Floating IP: 192.168.0.2

Follow the sub-instructions on each HAProxy server. At the time of this writing, the HAProxy configuration passes ALL SSL tests performed via https://www.ssllabs.com/ssltest with 100% Grade-A results.

For this setup, we will be using HAProxy and Keepalived for a cluster of load balancers. Each of the below steps will be performed on each HAProxy/Keepalived server, typically the only configuration differences are node-ids and which order nodes should fail-over. You'll need to install keepalived.

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