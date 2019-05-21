#/etc/puppet/modules/mailman3/manifests/core/logrotate.pp

class mailman3::core::logrotate (
  $logs_dir     = "${mailman3::core::config::vardir}/logs",
  $pid_file     = $mailman3::core::config::pidfile,
  $username     = $mailman3::core::username,
  $groupname    = $mailman3::core::groupname,
  $rotate       = 7,
  $rotate_every = 'daily',
  
){

  file { '/etc/logrotate.d/mailman':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mailman3/core/logrotate/mailman.erb')
  }

}
