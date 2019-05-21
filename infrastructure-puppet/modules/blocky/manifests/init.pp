#/etc/puppet/modules/blocky/manifests/init.pp

class blocky (
  $service_name   = 'blocky',
  $shell          = '/bin/bash',
  $service_ensure = 'running',
  $username       = 'root',
  $group          = 'root',
)
{

  require python
  
  if !defined(Python::Pip['netaddr']) {
    python::pip {
      'netaddr' :
        ensure => present;
    }
  }
  if !defined(Python::Pip['asfpy']) {
    python::pip {
      'asfpy' :
        ensure => present;
    }
  }
  if !defined(Python::Pip['requests']) {
    python::pip {
      'requests' :
        ensure => present;
    }
  }
  if !defined(Python::Pip['pyyaml']) {
    python::pip {
      'pyyaml' :
        ensure => present;
    }
  }
  
  exec { 'pkill -F /var/run/blocky.pid && rm /var/run/blocky.pid':
    cwd     => '/var/tmp',
    path    => ['/usr/bin', '/usr/sbin','/bin/',],
    onlyif  => 'test -f /var/run/blocky.pid'
  }

  cron {
    'restart_blocky':
      ensure  => absent, 
      user    => root,
      command => '/usr/sbin/service blocky restart',
      minute  => '5';
    }
    
  file {
    '/usr/local/etc/blocky':
      ensure => directory,
      mode   => '0755',
      owner  => $username,
      group  => $group;
    '/etc/init.d/blocky':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => "puppet:///modules/blocky/blocky.${::asfosname}";
    '/usr/local/etc/blocky/blocky.py':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => 'puppet:///modules/blocky/blocky.py';
    '/usr/local/etc/blocky/blocky.yaml':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => 'puppet:///modules/blocky/blocky.yaml';
    }

    -> service { $service_name:
        ensure    => $service_ensure,
        enable    => true,
        hasstatus => true,
        subscribe => [
          File['/usr/local/etc/blocky/blocky.py'],
          File['/usr/local/etc/blocky/blocky.yaml']
        ]
    }
}
