### I recommend verifying the RPM names as they do get updated once in a while

rpm -Uvh http://dl.fedoraproject.org/pub/epel/6Server/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm


### Now go set the repositories as enabled:
vim /etc/yum.repos.d/epel.repo
[epel]
enabled=1

vim /etc/yum.repos.d/remi.repo
[remi]
enabled=1

[remi-php56]
enabled=1

### Update repository cache ###
yum update