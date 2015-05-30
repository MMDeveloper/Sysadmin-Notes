We will make the following assumptions:
* AD Domain: mydomain.org
* NetBios Name: MYDOMAIN
* Domain Controller 0: DC0
* Domain Controller 1: DC1
* Domain Admin Account username (for joining to domain): dadmin000


### Install Prerequisites ###
```
yum -y install authconfig krb5-workstation pam_krb5 samba-common oddjob-mkhomedir samba-winbind nscd
```


### Configure authentication ###
```
authconfig --disablecache --enablewinbind --enablewinbindauth --smbsecurity=ads --smbworkgroup=MYDOMAIN --smbrealm=mydomain.org --enablewinbindusedefaultdomain --winbindtemplatehomedir=/home/MYDOMAIN/%U --winbindtemplateshell=/bin/bash --enablekrb5 --krb5realm=mydomain.org --enablekrb5kdcdns --enablekrb5realmdns --enablelocauthorize --enablemkhomedir --enablepamaccess --updateall
```

### replace /etc/krb5.conf with this data ###
```
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = mydomain.org
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 mydomain.org = {
  kdc = DC0.mydomain.org:88
  kdc = DC1.mydomain.org:88
  kdc = DC0
  kdc = DC1
  admin_server = DC0.mydomain.org:749
  default_domain = mydomain.org
 }

[domain_realm]
 .mydomain.org = mydomain.org
 mydomain.org = mydomain.org

[appdefaults]
 pam = {
   debug = false
   ticket_lifetime = 36000
   renew_lifetime = 36000
   forwardable = true
   krb4_convert = false
 }
```


### join machine to domain ###
```
net ads join mydomain.org -U dadmin000
```

reboot

Your SSH connections will now support both local accounts and LDAP accounts.
