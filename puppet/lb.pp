# haproxy.pp 
package { 'haproxy':
 ensure => installed
}
file { '/etc/haproxy/haproxy.cfg':
 ensure  => present,
 mode    => '0644',
 owner   => 'root',
 content => template('/vagrant/haproxy.cfg.boo'),
 notify  => Service['haproxy'],
}
file { '/etc/rsyslog.conf':
 ensure  => present,
 mode    => '0644',
 owner   => 'root',
 content => template('/vagrant/rsyslog.conf.boo'),
 notify  => Service['rsyslog'],
}
file { '/etc/rsyslog.d/haproxy.conf':
 ensure  => present,
 mode    => '0644',
 owner   => 'root',
 content => template('/vagrant/haproxy.conf.boo'),
 notify  => Service['haproxy'],
}
service { 'rsyslog':
 ensure  => running,
 name    => 'rsyslog',
 enable  => true,
 }
service { 'haproxy':
 ensure  => running,
 name    => 'haproxy',
 enable  => true,
 require => Package['haproxy'],
}