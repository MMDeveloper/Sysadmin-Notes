#Introduction#
SELinux is a security suite for Linux that I admittedly barely understand as I've always just disabled it. Due to boredom I've decided to start familiarizing myself with it.

Until my knowledge of this subject expands, I'll just put some common "fixme" things I've come across in my lab setting.

#SELinux is Denying X to do Y#
This is by far going to be the most common thing you come across. It may prevent your webserver (apache, nginx, whatever) from starting, or creating a socket file, or binding to a non-standard port, etc. Let's take my real world example.

Nginx was being prevented from starting because it binds to non-standard ports 180 and 8000 (it's behind a load balancer that runs on the same box in my lab). Below were the log outputs
```
grep nginx /var/log/audit/audit.log
>type=SERVICE_STOP msg=audit(1432087839.964:137448): pid=1 uid=0 auid=4294967295 ses=4294967295 msg=' comm="nginx" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
>type=AVC msg=audit(1432087988.964:60): avc:  denied  { name_bind } for  pid=1096 comm="nginx" src=180 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:reserved_port_t:s0 tclass=tcp_socket
>type=SYSCALL msg=audit(1432087988.964:60): arch=c000003e syscall=49 success=yes exit=0 a0=6 a1=7fdcc6d8dd10 a2=10 a3=7fffef094cf0 items=0 ppid=1 pid=1096 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
>type=AVC msg=audit(1432087988.964:61): avc:  denied  { name_bind } for  pid=1096 comm="nginx" src=8000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:soundd_port_t:s0 tclass=tcp_socket
>type=SYSCALL msg=audit(1432087988.964:61): arch=c000003e syscall=49 success=yes exit=0 a0=7 a1=7fdcc6d8dd60 a2=10 a3=7fffef094cf0 items=0 ppid=1 pid=1096 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
>type=AVC msg=audit(1432087989.057:62): avc:  denied  { name_bind } for  pid=1163 comm="nginx" src=8000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:soundd_port_t:s0 tclass=tcp_socket
>type=SYSCALL msg=audit(1432087989.057:62): arch=c000003e syscall=49 success=yes exit=0 a0=7 a1=7f991552dd40 a2=10 a3=7fff78406420 items=0 ppid=1 pid=1163 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
>type=AVC msg=audit(1432087989.080:63): avc:  denied  { setrlimit } for  pid=1199 comm="nginx" scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:system_r:httpd_t:s0 tclass=process
>type=SYSCALL msg=audit(1432087989.080:63): arch=c000003e syscall=160 success=yes exit=0 a0=7 a1=7fff784062f0 a2=0 a3=7f99141dab50 items=0 ppid=1196 pid=1199 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)
>type=SERVICE_START msg=audit(1432087989.480:64): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg=' comm="nginx" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
```

Since I trust and know that nginx is not trying to do anything malicious, I can just allow it to do whatever it is trying to do for now. We do this by running those logs through a utility called audit2allow which will generate policy files needed to allow the denied actions.

You can run individual log entries, or in my case I want to run them all (I cleared the audit log and restarted nginx so I had a 'clean slate' of logs).
```
grep nginx /var/log/audit/audit.log | audit2allow -M nginx
semodule -i nginx.pp
```
That will create a custom policy to allow nginx to do the things it was denied, and then load the policy.