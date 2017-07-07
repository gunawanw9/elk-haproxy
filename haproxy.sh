#!/bin/bash

sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum -y install puppet-agent
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

yum install -y iptables-services
systemctl mask firewalld
systemctl enable iptables
systemctl enable ip6tables
systemctl start iptables
systemctl start ip6tables

iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 5 -i eth0 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 5 -i eth1 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 5 -i eth1 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 5 -i eth2 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -I INPUT 5 -i eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
service iptables save
yum install -y net-tools
yum install -y sysstat

crontab -l | { cat; echo "*/1 * * * * /vagrant/logscripts/average"; } | crontab -