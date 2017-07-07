#!/bin/bash

mkdir -p /etc/pki/tls/certs
cp /vagrant/logstash-forwarder.crt /etc/pki/tls/certs
rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

touch /etc/yum.repos.d/elastic-beats.repo
echo '[beats]
name=Elastic Beats Repository
baseurl=https://packages.elastic.co/beats/yum/el/$basearch
enabled=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
gpgcheck=1' > /etc/yum.repos.d/elastic-beats.repo
yum -y install filebeat

yes | cp /vagrant/filebeat.yml /etc/filebeat/filebeat.yml
systemctl start filebeat
systemctl enable filebeat
