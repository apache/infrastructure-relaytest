#/etc/puppet/modules/mailman3/manifests/core.pp

class mailman3::core (
  $packages    = ['python3-dev'],
  $username    = 'mailman3',
  $groupname   = 'mailman3',
  $installroot = '/usr/local/mailman3-core',
) inherits ::mailman3::params {

  include mailman3
  include mailman3::core::config
  include mailman3::core::logrotate

  package { $packages:
    ensure => present,
  }

  group { $groupname:
    ensure => present,
    system => true,
  }->

  user { $username:
    ensure     => present,
    gid        => $groupname,
    home       => "/home/${username}",
    system     => true,
    managehome => true,
    shell      => '/bin/bash',
    require    => Group[$groupname],
  }->

  file {
    $installroot:
      ensure  => directory,
      owner   => $username,
      group   => $groupname,
      mode    => '0755',
      require => User[$username];
    "${installroot}/mailman.txt":
      ensure  => present,
      owner   => $username,
      group   => $groupname,
      mode    => '0644',
      source  => 'puppet:///modules/mailman3/requirements/mailman.txt';
    '/var/run/mailman':
      ensure => directory,
      owner  => $username,
      group  => $groupname,
      mode   => '0755';
    '/etc/init.d/mailman3':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('mailman3/mailman3_init.erb');
  }->


  # Because pyvenv in ubuntu 14.04 broke, manually create it for now

  case $::operatingsystem {
    'Ubuntu': {
      case $::operatingsystemrelease { # lint:ignore:case_without_default
        '14.04': {
          exec { 'create python3 venv':
            command => 'virtualenv -p python3 venv3',
            cwd     => $installroot,
            creates => "${installroot}/venv3/bin/activate",
            user    => $username,
            group   => $groupname,
            path    => [ '/bin', '/usr/bin', '/usr/sbin', '/usr/local/bin' ],
            require => [ Package['python-virtualenv'], User[$username] ],
          }
        }
      }
    }
    default: {
      python::pyvenv { "${installroot}/venv3":
        ensure => present,
        owner  => $username,
        group  => $username,
      }
    }
  }->

  python::requirements {
    'mailman3.txt':
      requirements => "${installroot}/mailman.txt",
      cwd          => $installroot,
      virtualenv   => "${installroot}/venv3",
      owner        => $username,
      group        => $groupname,
      require      => [ Package['python3-dev'], File["${installroot}/mailman.txt"] ],
      notify       => Service['mailman3'],
  }->

  service { 'mailman3':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    require    => File['/etc/init.d/mailman3', '/etc/mailman.cfg'],
  }



}
