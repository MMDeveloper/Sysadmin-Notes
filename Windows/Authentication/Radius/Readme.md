#Installation#
From your server manager, add the Network Policy and Access Services role.

#Configuration#
First we need to open the new Network Policy Server management console.

Radius authentication is popular with wireless installations. NPS and Radius has a vast array of uses but in my experience, the most common usage is for wireless authentication. We will setup a wireless authentication radius server.


First let's create a shared secret template. This is so we can simply apply the secret template to all radius clients (currently only one WAP). That way, if we ever need to change the secret, we only update the template.
 - Expand "Templates Management"
 - right click Shared Secrets
 - click New
 - type or generate your secret, and give it a meaningful name

Now we need to define our radius clients. This is a list of IPs/Ranges of devices that will be allowed to attempt radius authentication. Typically this will be IPs of your wireless access points, or your wireless controller (if applicable), or external IPs if you use a cloud based wireless management (such as Meraki). Expand "Radius Clients and Servers" and add your radius clients.

Now we need to define our Radius Server Groups. This will be a group of servers that are capable of actually validating credentials, typically this will be your domain controllers.

After that, expand Policies and click Connection Request Policies. There will be a default policy that pretty much allows anyone. We will delete this policy and create a new one.

 - Give it a meaningful name
 - Leave "type" as Unspecified if you're going 802.1X wireless authentication.
 - Now specify the conditions that this policy applies. You need at least one condition. If you want this one policy to apply to all, just add a day/time restriction and Permit All, 24/7
 - Now we determine where authentication is held. If this is an A/D environment, you can defer authentication to your domain controllers. If this is running ON a domain controller, you can do authentication "on this server".
 - Specify the authentication methods you will support, the most common setup is MSCHAPv2 only (with password change option).
