These instructions should be performed on ALL webservers. It's important you keep each webserver identical to one another so the runtime environments are the same no matter which server a user is load balanced on. If you want, you can do the install and clone the webserver to as many as you want. Be sure to do this BEFORE you start the Cluster Storage sections.

I prefer nginx all day over any other webserver. After installation typically I'll create the following directory structure:

slow-sync'd directories here. This is covered under Cluster Storage only used for shared config files and such
```
mkdir -p /var/www/internal/conf/nginx/sites-enabled/
mkdir -p /var/www/internal/conf/nginx/sites-available/
```

fast-sync'd directories here. This is covered under Cluster Storage. This is typically just created for a later mount point. Subdirectories in here will be where externally visible content goes
```
mkdir -p /var/www/external
```

the 'internal' folder is used for config files and other 'portable' items that don't need realtime syncing, rather a slower sync schedule is fine. The reasoning for this is covered under Cluster Storage. The 'external'folder is where you place your content to be viewable to the world. In this folder I typically create one subfolder per FQDN being hosted, such as:
```
/var/www/external/www.youtube.com/
/var/www/external/static.cnn.com/
```
