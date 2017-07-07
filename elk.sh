#!/bin/bash

# Install Elasticsearch
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

echo '[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
' | sudo tee /etc/yum.repos.d/elasticsearch.repo

yum -y install elasticsearch

echo "network.host: localhost
http.port: 9200" >> /etc/elasticsearch/elasticsearch.yml
systemctl start elasticsearch
systemctl enable elasticsearch

# Install Kibana
echo '[kibana-4.4]
name=Kibana repository for 4.4.x packages
baseurl=http://packages.elastic.co/kibana/4.4/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1' > /etc/yum.repos.d/kibana.repo

yum -y install kibana
echo 'server.host: "localhost"' >> /opt/kibana/config/kibana.yml
systemctl start kibana
chkconfig kibana on

# Install nginx
yum -y install epel-release
yum -y install nginx httpd-tools
htpasswd -c /etc/nginx/htpasswd.users kibanaadmin

yes | cp /vagrant/nginx.conf /etc/nginx/nginx.conf

touch /etc/nginx/conf.d/kibana.conf
echo 'server {
	listen 80;

	server_name example.com;

	auth_basic "Restricted Access";
	auth_basic_user_file /etc/nginx/htpasswd.users;

	location / {
		proxy_pass http://localhost:5601;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host $host;
		proxy_cache_bypass $http_upgrade;        
	}
}' > /etc/nginx/conf.d/kibana.conf
systemctl start nginx
systemctl enable nginx
setsebool -P httpd_can_network_connect 1

# From this moment we can access kibana
# Now, Install Logstash

echo '[logstash-2.2]
name=logstash repository for 2.2 packages
baseurl=http://packages.elasticsearch.org/logstash/2.2/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1' > /etc/yum.repos.d/logstash.repo
yum -y install logstash

mkdir -p /etc/pki/tls/certs
mkdir /etc/pki/tls/private
touch /tmp/openssl.cnf.tmp
awk '1;/\[ v3_ca \]/{ print "subjectAltName = IP: 172.16.24.3" }' /etc/pki/tls/openssl.cnf > /tmp/openssl.cnf.tmp
yes | cp /tmp/openssl.cnf.tmp /etc/pki/tls/openssl.cnf

# Generate SSL Certificate
cd /etc/pki/tls
openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt

# Configure Logstash
touch /etc/logstash/conf.d/02-beats-input.conf
echo 'input {
  beats {
	port => 5044
	ssl => true
	ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
	ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}' > /etc/logstash/conf.d/02-beats-input.conf

cp /vagrant/10-syslog-filter.conf /etc/logstash/conf.d/

touch /etc/logstash/conf.d/30-elasticsearch-output.conf
echo 'output {
  elasticsearch {
	hosts => ["localhost:9200"]
	sniffing => true
	manage_template => false
	index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
	document_type => "%{[@metadata][type]}"
  }
}' > /etc/logstash/conf.d/30-elasticsearch-output.conf

# Check and apply:
service logstash configtest
systemctl restart logstash
chkconfig logstash on

# Load Kibana Dashboard
cd ~
curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip
yum -y install unzip
unzip beats-dashboards-*.zip
cd beats-dashboards-*
./load.sh
rm ./../beats-dashboards-1.1.0.zip -y

# Load Filebeat Index Template in Elasticsearch
cd ~
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

# Copy cert to client
cp /etc/pki/tls/certs/logstash-forwarder.crt /vagrant/