# elk-haproxy
<p> elk server, haproxy-based load balancer and a backend machine <p>
## Run 
``` host$ vagrant up ```
``` backend$ puppet apply /vagrant/puppet/back.pp ```
``` haproxy$ puppet apply /vagrant/puppet/lb.pp```
``` elk$ bash /vagrant/elk.sh ```
<h1> This will do the job. </h1>
## Then, if u want to set logging on haproxy:
``` haproxy$ bash /vagrant/elk_client-config.sh ```
<p> So, now it is going to be done. <b> NOTE: I spent a large amount of time doing this configs to set logging haproxy access logs NOT to syslog but directly to custom logs. Then they are parsed to Kibana. </b> </p> 