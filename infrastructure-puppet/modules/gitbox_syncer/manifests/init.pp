#/etc/puppet/modules/gitbox_syncer/manifests/init.pp

class gitbox_syncer (
  $service_name   = 'gitbox-syncer',
  $shell          = '/bin/bash',
  $service_ensure = 'running',
  $username       = 'root',
  $group          = 'root',
)
{

  
  require python
  
  if !defined(Python::Pip['gunicorn']) {
    python::pip {
      'gunicorn' :
        ensure => present;
    }
  }
  if !defined(Python::Pip['netaddr']) {
    python::pip {
      'netaddr' :
        ensure => present;
    }
  }
  if !defined(Python::Pip['asfpy']) {
    python::pip {
      'asfpy' :
        ensure  => present;
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
        ensure  => present;
    }
  }

  file {
    '/usr/local/etc/gitbox-syncer':
      ensure => directory,
      mode   => '0755',
      owner  => $username,
      group  => $group;
    '/var/run/gitbox-syncer':
      ensure => directory,
      mode   => '0755',
      owner  => 'www-data',
      group  => 'www-data';
    '/etc/init.d/gitbox-syncer':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => "puppet:///modules/gitbox_syncer/gitbox-syncer.${::operatingsystem}";
    '/usr/local/etc/gitbox-syncer/gitbox-syncer.py':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => 'puppet:///modules/gitbox_syncer/gitbox-syncer.py';
    '/usr/local/etc/gitbox-syncer/gitbox-syncer.yaml':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => 'puppet:///modules/gitbox_syncer/gitbox-syncer.yaml';
    '/usr/local/etc/gitbox-syncer/github_sync.py':
      mode   => '0755',
      owner  => $username,
      group  => $group,
      source => 'puppet:///modules/gitbox_syncer/github_sync.py';
    }
    -> service { $service_name:
        ensure    => $service_ensure,
        enable    => true,
        hasstatus => true,
        subscribe => [
          File['/usr/local/etc/gitbox-syncer/gitbox-syncer.py'],
          File['/usr/local/etc/gitbox-syncer/gitbox-syncer.yaml']
        ]
    }
}
