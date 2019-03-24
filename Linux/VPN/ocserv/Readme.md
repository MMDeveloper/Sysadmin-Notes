#Assumptions#

For the purposes of this document, we will assume:

* the working directory for ocserv is /etc/pki/ocserv/
* You want certificate based authentication only
* The URL to your VPN endpoint is vpn.example.com
* We'll be generating a cert for one user (user000) on one device (device000; these steps can be repeated as needed)

#Installation#

Install `ocserv` from the repository

#Daemon Configuration#

```
vi /etc/ocserv/ocserv.conf
```

replace the contents with this

```
auth = "certificate"
enable-auth = "certificate"
tcp-port = 1194
udp-port = 1194
run-as-user = ocserv
run-as-group = ocserv
socket-file = ocserv.sock
chroot-dir = /var/lib/ocserv
isolate-workers = true
banner = "gtfo bitch"
max-clients = 2
max-same-clients = 2
keepalive = 32400
dpd = 90
mobile-dpd = 1800
switch-to-tcp-timeout = 25
try-mtu-discovery = false
server-cert = /etc/pki/ocserv/servercerts/server-cert.pem
server-key = /etc/pki/ocserv/servercerts/server-key.pem
ca-cert = /etc/pki/ocserv/cacerts/ca-cert.pem
cert-user-oid = 2.5.4.3
compression = true
tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-VERS-SSL3.0"
auth-timeout = 240
min-reauth-time = 300
max-ban-score = 50
ban-reset-time = 300
cookie-timeout = 300
deny-roaming = false
rekey-time = 172800
rekey-method = ssl
use-occtl = true
pid-file = /var/run/ocserv.pid
device = vpns
predictable-ips = true
default-domain = example.com
ipv4-network = 10.0.3.0
ipv4-netmask = 255.255.255.0
dns = 10.0.1.1
dns = 1.1.1.1
ping-leases = false
route = default
cisco-client-compat = false
dtls-legacy = false
user-profile = profile.xml
```

#Certificate Templates#

First we need to create certificate templates for the internal CA, Server, and User.

vi /etc/pki/ocserv/ca.tmpl
```
cn=vpn.example.com
expiration_days=9999
serial=1
ca
cert_signing_key
```

vi /etc/pki/ocserv/server.tmpl
```
cn=vpn.example.com
serial=2
expiration_days=9999
signing_key
encryption_key
```

vi /etc/pki/ocserv/user.tmpl
```
cn = "user"
unit = "admins"
expiration_days = 9999
signing_key
tls_www_client
```
#Certificate Generation#

Let's generate the CA certificate

```
mkdir -p /etc/pki/ocserv/cacerts/
cd /etc/pki/ocserv/cacerts/
certtool --generate-privkey --outfile ca-key.pem --sec-param=ultra --rsa
certtool --generate-self-signed --load-privkey ca-key.pem --template ../ca.tmpl --outfile ca-cert.pem --sec-param=ultra --rsa
```

Let's generate the Server certificate

```
mkdir -p /etc/pki/ocserv/servercerts/
cd /etc/pki/ocserv/servercerts/
certtool --generate-privkey --outfile server-key.pem --sec-param=ultra --rsa
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ../cacerts/ca-cert.pem  --load-ca-privkey ../cacerts/ca-key.pem  --template ../server.tmpl  --outfile server-cert.pem --sec-param=ultra --rsa
```

For each user/device combination, we'll want to generate a unique certificate chain.

```
mkdir -p /etc/pki/ocserv/users/user000/device000/
cd /etc/pki/ocserv/users/user000/device000/
certtool --generate-privkey --outfile user-key.pem --sec-param=ultra --rsa
certtool --generate-certificate --load-privkey user-key.pem --load-ca-certificate ../../../cacerts/ca-cert.pem  --load-ca-privkey ../../../cacerts/ca-key.pem  --template ../../../server.tmpl  --outfile user-cert.pem --sec-param=ultra --rsa
```

#Copying certs to user device#

To enable the VPN communication on the end device, you'll need to copy the /etc/pki/ocserv/cacerts/ca-cert.pem , /etc/pki/ocserv/users/user000/device000/user-key.pem , and /etc/pki/ocserv/users/user000/device000/user-cert.pem files to that device.