#Installation#
Open the Server Manager and add the DNS role. Click through the wizard steps until completion. After install, open the DNS management tool.

#Configure Primary DNS Node#
Now we need to configure a zone. For the purposes of this documentation, we'll assume we're going to host the domain "mydomain.com" with 2 subdomains of "www" and "static" with IPs of 192.168.0.3 and 4 respectively.

Now let's finalize the dns server config
0. Right click on the server name in the DNS management window and click on Properties
1. Click Advanced, Enable Scavenging.


Now let's create our first forward and reverse zones.

0. Right click on the Forward Lookup Zone and click on "New Zone".
1. Create a Primary Zone
2. zone name will be "mydomain.com"
3. Do not allow dynamic updates
4. Now right click on Reverse Lookup Zone and click on "New Zone".
5. Create a Primary Zone
6. IPv4 Zone
7. input the first three octets of IP addresses to go with your forward zone (192.168.0)
8. Do not allow dynamic updates

Now we have your forward and reverse zones, we need to create your host records in your forward zone.

0. Navigate to your forward zone of mydomain.com
1. right click in the empty space and choose "New Host (A or AAAA)"
2. in the Name field, type www
3. In the IP address field type 192.168.0.3
4. Check the "create pointer record" box
5. Click "Add Host".
6. Repeat those steps for the 'static' subdomain with the .4 address.
