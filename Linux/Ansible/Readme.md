#Installation#
```
dnf install ansible-core
mkdir /etc/ansible/sshKeys/
chmod 700 /etc/ansible/sshKeys/
```

#Configuration of Server#
```
vim /etc/ansible/ansible.cfg
#change the pointer of the inventory file to this
inventory=/etc/ansible/inventory.yaml
#save and exit

vim /etc/ansible/inventory.yaml
#see sample yaml file
```

#Adding a managed Linux node#
SSH to the node to be managed by Ansible and elevate to root
```
useradd ansible
visudo
    #locate the line granting WHEEL group privileges and add this under it
    ansible ALL=(ALL) NOPASSWD: ALL
    #save and exit file
su ansible
cd ~
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat ~/.ssh/id_ed25519
```
Copy the private key contents. Now SSH back to the Ansible server and put the key in /etc/ansible/sshKeys/ with a unique filename. Edit your inventory.yaml file to associate the key with the appropriate managed nodes.

Now let's do a test "ansible ping" from the ansible server using the exact resource name from the inventory file
ansible -m ping alias_webservernode0.fqdn.edu

Refer to so sample playbooks for updating, rolling reboots, etc. You would run a playbook via
```
ansible-playbook /etc/ansible/playbooks/update-reboot_loadbalancers.yaml
```