#/etc/puppet/modules/mailman3/manifests/hyperkitty.pp

class mailman3::hyperkitty (
  $packages    = ['nodejs-legacy', 'node-less'],
  $installroot = '/var/www/hyperkitty',
) inherits ::mailman3::params {

  include mailman3
  include mailman3::hyperkitty::config

  require apache

  package { $packages:
    ensure => present,
  }

  file {
    $installroot:
      ensure => directory,
      owner  => $apache::user,
      group  => $apache::group,
      mode   => '0755';
    "${installroot}/hyperkitty.txt":
      ensure => present,
      owner  => $apache::user,
      group  => $apache::group,
      mode   => '0644',
      source => 'puppet:///modules/mailman3/requirements/hyperkitty.txt';
    "${installroot}/hyperkitty_standalone":
      ensure  => directory,
      owner   => $apache::user,
      group   => $apache::group,
      recurse => true,
      before  => Class[mailman3::hyperkitty::config],
      source  => 'puppet:///modules/mailman3/hyperkitty';
    "${installroot}/hyperkitty_standalone/wsgi.py":
      ensure  => present,
      owner   => $apache::user,
      group   => $apache::group,
      before  => Class[mailman3::hyperkitty::config],
      content => template('mailman3/hyperkitty/wsgi.py.erb'),
      require => File["${installroot}/hyperkitty_standalone"];
  }->

  python::virtualenv {
    "${installroot}/venv2":
      ensure       => present,
      requirements => "${installroot}/hyperkitty.txt",
      owner        => $apache::user,
      group        => $apache::group,
      require      => File["${installroot}/hyperkitty.txt"],
  }->

  exec { 'hyperkitty collectstatic':
    command => "${installroot}/venv2/bin/django-admin.py collectstatic --noinput --pythonpath ${installroot}/hyperkitty_standalone --settings local_settings",
    creates => "${installroot}/hyperkitty_standalone/static/hyperkitty",
    cwd     => "${installroot}/hyperkitty_standalone",
    user    => $apache::user,
    require => File["${installroot}/hyperkitty_standalone"],
  }->

  exec { 'hyperkitty compress':
    command => "${installroot}/venv2/bin/django-admin.py compress --pythonpath ${installroot}/hyperkitty_standalone --settings local_settings --force",
    creates => "${installroot}/hyperkitty_standalone/static/CACHE",
    cwd     => "${installroot}/hyperkitty_standalone",
    user    => $apache::user,
    require => [ File["${installroot}/hyperkitty_standalone"], Package[$packages] ],
  }

}
