global
    log 	127.0.0.1 local2
    chroot      /var/lib/haproxy
    stats socket /var/lib/haproxy/stats
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen haproxy3-monitoring *:8080
    mode http
    option forwardfor
    option httpclose
    stats enable
    stats show-legends
    stats refresh 5s
    stats uri /stats
    stats realm Haproxy\ Statistics
    stats auth stats:stats
    stats admin if TRUE
    default_backend rx2_backend80

userlist usersss
    user devops insecure-password 123qwe

frontend rx2_frontend80
	acl auth_ok http_auth(usersss)
    bind *:80
	http-request auth unless auth_ok
    option http-server-close
    option forwardfor
    default_backend rx2_backend80

backend rx2_backend80
    option httpchk GET /
    balance roundrobin
    cookie rx2s_id insert indirect nocache
    timeout check 20000
    server backend 172.16.24.34:80 check

