# Max open file descriptors
fs.file-max = 331287

# TCP Tuning
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65023
net.ipv4.tcp_max_syn_backlog = 10240
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.tcp_max_orphans = 60000
net.ipv4.tcp_synack_retries = 3
net.core.somaxconn = 40000
net.ipv4.tcp_rmem = 4096 8192 16384
net.ipv4.tcp_wmem = 4096 8192 16384
net.ipv4.tcp_mem = 65536 98304 131072
net.core.netdev_max_backlog = 40000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1