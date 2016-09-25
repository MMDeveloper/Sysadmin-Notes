#Installation of HAProxy on CentOS 6#
```
yum install haproxy
chkconfig --add haproxy
chkconfig --level 345 haproxy on
```

#Installation of HAProxy on CentOS 7#
```
yum install haproxy
systemctl enable haproxy.service
```

#Certificate Pinning#
If you want to use public certificate pinning to thwart MITM attacks, you'll first need to extract the base64 encoded version of your SPKI fingerprint. If your SSL Cert is already installed and working, run this command
```
openssl s_client -servername www.example.com -connect www.example.com:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
```
where 'www.example.com' is replaced with your domain name. That output will produce a line that looks like this
```
writing RSA key
+EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw=
```
where +EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw= is the SPKI fingerprint (yours will be different). Now that you have obtained this, we will need to add this line to the HTTPS frontend of your haproxy config
```
rspadd Public-Key-Pins:\ pin-sha256="+EDTr/eN7pj1UWjmsTZzXpllJ+m6QbPDgZhIWbE9zrw=";\ max-age=5184000;\ includeSubDomains
```