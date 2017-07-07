# elk-haproxy
<h1> made by [progressivesasha](https://github.com/progressivesasha/) . If you have any questions, feel free to contact me: a.nekrasov.opsdev@gmail.com </h1>
<p> elk server, haproxy-based load balancer and a backend machine <p>

# Run 

```
host$ vagrant up
```

```
backend$ puppet apply /vagrant/puppet/back.pp
```

```
haproxy$ puppet apply /vagrant/puppet/lb.pp
```

```
elk$ bash /vagrant/elk.sh
```

<h1> This will do the job. </h1>

# Then, if u want to enable logging on haproxy:

```
haproxy$ bash /vagrant/elk_client-config.sh
```

<p> So, now it is going to be done. <b> NOTE: I spent a large amount of time doing this configs to set logging haproxy access logs NOT to syslog but directly to custom logs. Then they are parsed to Kibana. </b> </p> 

# File explanation:

* 10-syslog-filter.conf -- Grok filters to parse the data;
* backend.sh -- backend server's provisioning script;
* haproxy.sh -- load balancer's provisioning script;
* elkprov.sh -- simple provisioning script for elk server. Installs only java;
* elk.sh -- configuration script for elk server. Launch it by yourself after machine being provisioned;
* elk_client-config.sh -- configurates filebeat for ELK client to send logs;
* puppet/back.pp -- run *$puppet apply* to set up LAMP stack. index.php file will be placed in /var/www/html as main page;
* puppet/lb.pp -- run *$puppet apply* to set up Haproxy load balancing;
* logscripts/average -- my little sysstat script that monitors average load on Haproxy server. Fits in crontab;
* elasticsearch.yml -- elasticsearch config file;
* filebeat.yml -- figures which log to read and how to handle it;
* haproxy.cfg.BOO -- I named it that way just for fun actually :D This is the main config for haproxy;
* haproxy.conf.BOO -- Same story. But this config does not the same things. It specifies which logs to read and where they might be directed;
* nginx.conf -- nginx configuration file.
* rsyslog.conf.BOO -- main rsyslog configuration file.

