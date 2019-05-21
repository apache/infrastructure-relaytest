#/etc/puppet/modules/mailman3/manifests/postorius.pp

class mailman3::postorius (
  $packages    = [], # put any packages needed by postorius's vitualenv, such as postgres-dev for psycopg2
  $installroot = '/var/www/postorius',
) inherits ::mailman3::params {

  include mailman3
  include mailman3::postorius::config

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
    "${installroot}/postorius.txt":
      ensure => present,
      owner  => $apache::user,
      group  => $apache::group,
      mode   => '0644',
      source => 'puppet:///modules/mailman3/requirements/postorius.txt';
    "${installroot}/postorius_standalone":
      ensure  => directory,
      owner   => $apache::user,
      group   => $apache::group,
      recurse => true,
      before  => Class[mailman3::postorius::config],
      source  => 'puppet:///modules/mailman3/postorius';
  }->

  python::virtualenv {
    "${installroot}/venv2":
      ensure       => present,
      requirements => "${installroot}/postorius.txt",
      owner        => $apache::group,
      group        => $apache::group,
      require      => Package[$packages],
  }->

  exec { 'postorius collectstatic':
    command => "${installroot}/venv2/bin/python manage.py collectstatic --noinput",
    creates => "${installroot}/postorius_standalone/static/postorius",
    cwd     => "${installroot}/postorius_standalone",
    user    => $apache::user,
    require => File["${installroot}/postorius_standalone"],
  }
}
