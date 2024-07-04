#Installation#
```
yum install ntp
systemctl enable ntpd.service
```

#Configuration#
go to http://www.pool.ntp.org/en/ and drill down to find a pool of stratum servers to sync with
```
vim /etc/ntp.conf
```
> ####Paste the contents below####

```
server 0.north-america.pool.ntp.org
server 1.north-america.pool.ntp.org
server 2.north-america.pool.ntp.org
server 3.north-america.pool.ntp.org

### we also need to restrict the NTP service to your LAN
### we will assume you're serving the 192.168.0.1-254 subnet
restrict 192.168.0.0 netmask 255.255.255.0 nomodify notrap
```

restart the NTP service and verify functionality.
```
ntpq -p
```

#Firewall#
First we need to determine which zones are active
```
firewall-cmd --get-active-zones
```
In my dev environment, I only have one zone called `internal` active. Now we open the NTP port for the target zone
```
firewall-cmd --zone=internal --add-port=123/udp --permanent
```