# Adapted from https://github.com/example42/puppet-postfix/blob/master/manifests/aliases.pp

class postfix::aliases (
  $maps = undef,
  $config_file_mode = '0644',
  $config_file_owner = 'root',
  $config_file_group = 'root',
  $aliases_file = '/etc/aliases',

) inherits ::postfix::params {

  $aliases = hiera_hash('postfix::aliases::maps', undef)

   file { 'postfix::aliases':
     ensure  => present,
     path    => "${::postfix::params::config_directory}/aliases",
     mode    => $config_file_mode,
     owner   => $config_file_owner,
     group   => $config_file_group,
     require => Package['postfix'],
     content => template('postfix/aliases.erb'),
   }

   file { 'postfix::aliases_sym':
     path   => $aliases_file,
     ensure => 'symlink',
     target => "${::postfix::params::config_directory}/aliases",
   }

   exec { 'postalias':
     command     => "/usr/sbin/postalias '${aliases_file}'",
     require     => Package['postfix'],
     subscribe   => File['postfix::aliases'],
     refreshonly => true,
   }

}
