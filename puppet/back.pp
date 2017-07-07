package {'php':
  ensure => present,  
  before => File['/etc/php.ini'],
}
file {'/etc/php.ini':
  ensure => file,
}

package {'httpd':
  ensure => present,
}
service {'httpd':
  ensure => running,
  enable => true,
  require => Package['httpd'],
  subscribe => File['/etc/php.ini'],
}
file { '/var/www/html/index.php':
 ensure  => present,
 mode    => '0644',
 owner   => 'root',
 content => template('/vagrant/index.php.erb'),
 notify  => Service['httpd'],
}
