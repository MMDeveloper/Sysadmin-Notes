#Installation#
From your server manager, install the Active Directory Domain Services role. After install, you must configure your first DC.

#Configuration#
Historically you would run dcpromo from an elevated command prompt, however in 2012 you have to run a setup wizard from the server manager window under the "Notifications" icon.

 - You will be creating a new domain in a new forest.
 - Think carefully what you want your domain to be, I will use internal.org
 - I recommend using the highest forest functional level available which in this case is 2008R2. Keep in mind that if you have a functional level of 2012, you cannot have any 2008 domain controllers so take that into account. Have the functional level as high as the Domain Controller with the oldest OS.
 - Choose a Restore Mode password. This is when stuff really hits the fan. Keep this secret somewhere.


 After reboot, login and open Sites and Services. Rename the "Default First Site" to something meaningful to you, maybe "District Office". We now need to add your networks Subnets. Under Sites, right click on "Subnets" and choose New Subnet. Input your subnet information. Do this for all of your networks internal subnets. Associate the subnets to the Sites they apply to.
