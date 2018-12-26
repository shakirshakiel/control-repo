# Class: profile::puppetboard
#
# Puppetboard is a WebUI to inspect PuppetDB
#
class profile::puppetboard {

  include ::apache

  $puppetboard_certname = $trusted['certname']
  $ssl_dir = '/etc/httpd/ssl'

  file { $ssl_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${ssl_dir}/certs":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${ssl_dir}/private_keys":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
  }

  file { "${ssl_dir}/certs/ca.pem":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "${::settings::ssldir}/certs/ca.pem",
    before => Class['::puppetboard'],
  }

  file { "${ssl_dir}/certs/${puppetboard_certname}.pem":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "${::settings::ssldir}/certs/${puppetboard_certname}.pem",
    before => Class['::puppetboard'],
  }

  file { "${ssl_dir}/private_keys/${puppetboard_certname}.pem":
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "${::settings::ssldir}/private_keys/${puppetboard_certname}.pem",
    before => Class['::puppetboard'],
  }

  class { '::puppetboard':
    groups              => 'root',
    manage_git          => true,
    manage_virtualenv   => true,
    manage_selinux      => false,
    puppetdb_host       => 'puppet-master-tw.novalocal',
    puppetdb_port       => 8080,
    reports_count       => 40,
  }

  class { '::apache::mod::wsgi':
    wsgi_socket_prefix => '/var/run/wsgi',
  }

  class { '::puppetboard::apache::vhost':
    vhost_name => 'puppetboard.example.com',
    port       => 80,
  }
}