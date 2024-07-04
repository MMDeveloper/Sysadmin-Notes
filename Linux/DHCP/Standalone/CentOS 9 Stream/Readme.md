#Installation#
```
yum install dhcpd
systemctl enable dhcpd.service
```

#Configuration#
```
vim /etc/dhcp/dhcpd.conf
```
> ####Paste the contents of configs/dhcpd.conf####

#Integration With BIND#
If you have DHCPD running on a linux box and wish to push DDNS to your BIND server, there is a little bit more config to do.

First we need to generate a rndc key
```
dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 128 -n USER DHCP_UPDATER
cat Kdhcp_updater.*.private|grep Key
>>Key: asdfasdfasdfasdf/adsf==
```
Now we need to make a few config changes to dhcpd.conf

```
vim /etc/dhcp/dhcpd.conf
```
Place the following configuration directives at the top of the file, ignoring duplicates, updating existing
```
authoritative;
ddns-updates on;
ddns-update-style interim;
use-host-decl-names on;
ignore client-updates;
ddns-domainname "yourlocaldnsdomain.com.";
ddns-rev-domainname "2.0.10.in-addr.arpa.";


key DHCP_UPDATER {
    algorithm HMAC-MD5.SIG-ALG.REG.INT;

    # Important: Replace this key with your generated key.
    # Also note that the key should be surrounded by quotes.
    secret "asdfasdfasdfasdf/adsf==";
};


zone yourlocaldnsdomain.com. { #the dns suffix domain
    primary 10.0.2.1; #the IP address of the BIND server
    key DHCP_UPDATER;
}

zone 2.0.10.in-addr.arpa. { #the reverse lookup zone
    primary 10.0.2.1; #the IP address of the BIND server
    key DHCP_UPDATER;
}
```

Now, in your subnet config, just add the DNS suffix if it's not already there
```
option domain-name "yourlocaldnsdomain.com";
```

Now refer to BIND's documentation for its half of this relationship and restart both DHCP and Bind and you should be good to go.
