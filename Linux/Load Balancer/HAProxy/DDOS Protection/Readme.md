#TCP syn flood attacks#
This is handled at the OS layer. Just set these parameters in the sysctl config file and you're good to go.
```
vim /etc/sysctl.conf
```

Add/update these entries
```
# Protection SYN flood
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_max_syn_backlog = 1024
```

#Slowloris like attacks#
Protection form this is already in my sample configs, but the relevant entries are placed in the `globals` section of your haproxy config file
```
timeout http-request    5s
timeout queue           1m
timeout connect         5s
timeout client          5s
timeout server          10s
timeout http-keep-alive 10s
timeout check           10s
```

#General Traffic Flooding#
This configuration is site-specific. You may need to tweak the numbers to meet your needs. This config is already in my sample config (for a low traffic, optimized site) but here are the relevant entries. You'd do this for each frontend.

```
stick-table type ip size 100k expire 30s store conn_cur,conn_rate(10s),http_req_rate(10s),http_err_rate(10s)
tcp-request connection track-sc0 src

# Reject if client has more than X concurrent connections
http-request add-header X-Haproxy-Throttle %[req.fhdr(X-Haproxy-Throttle,-1)]active-connections, if { src_conn_cur ge 10 }
# Reject if client has passed the HTTP connection rate
http-request add-header X-Haproxy-Throttle %[req.fhdr(X-Haproxy-Throttle,-1)]connection-rate, if { src_conn_rate ge 30 }
# Reject if client has passed the HTTP error rate
http-request add-header X-Haproxy-Throttle %[req.fhdr(X-Haproxy-Throttle,-1)]error-rate, if { sc0_http_err_rate() gt 10 }
# Reject if client has passed the HTTP request rate
http-request add-header X-Haproxy-Throttle %[req.fhdr(X-Haproxy-Throttle,-1)]request-rate, if { sc0_http_req_rate() gt 80 }

#acls
acl use_be_slowdown_chump req.fhdr(X-Haproxy-Throttle) -m found
```

Now for the backend that's used if any of the thresholds are met
```
backend be_slowdown_chump
    mode http
    timeout tarpit 15s
    errorfile 503 /usr/share/haproxy/ratelimit.http
    errorfile 504 /usr/share/haproxy/ratelimit.http
```

The ratelimit.http is a small plain text file with a message to the abuser. They'll be stuck with that response for 15 seconds.