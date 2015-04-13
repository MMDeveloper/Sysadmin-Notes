#Installation#
From your server manager, install the Windows Server Update Services role. After install, you must configure your new WSUS box.

#Configuration#
The most common WSUS install is a single server acting as an update caching server for networks, so we will assume this is the desired setup.

Open the WSUS Management console, it should prompt a "first run" type config wizard

 - You want to sync from Microsoft Update
 - Select the languages you want to support, in my case, it's only English
 - Choose the products you want to supply updates for. When you configure your workstations/servers to use your WSUS server, they will only pull updates from your WSUS server so make sure you cover all your bases when selecting what products to pull updates for.
 - Select the update types you want to download and issue.
 - Choose a sync schedule that will minimize bandwidth impact. This is when your WSUS server will sync updates from Microsoft.
 - Personally I'd recommend to defer the first sync for the next scheduled sync, else it will pull down a LOT of update data from MS which can kill small internet pipes.

Now you need to direct your workstations and servers to use your WSUS server. You're more than likely putting this in an Active Directory environment which makes this very easy. Simply create a new GPO called "WSUS" and set these options:
  - Computer Configuration -> Administrative Templates -> Windows Components - Windows Update
  -> Click Specify Intranet Microsoft Update Service Location
  -> Click Enabled
  -> In both boxes, type https://%FQDN_WSUS_Server% for example, https://wsus000.internal.local
  -> Click Configure Automatic Updates
  ->> Configure your update install schedule for clients
  -> Click Enable client-side targeting
  -> Click Enabled

Set any additional update options as needed. I would not yet approve, or configure auto approval, until at least your windows servers have populated themselves into WSUS. You will want to schedule different update policies to your servers and workstations. Once you feel comfortable there is adequate segregation, configure your auto approval policies and you're done.
