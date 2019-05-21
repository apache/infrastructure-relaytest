# /etc/puppet/modules/mailman3/manifests/core/hyperkitty_integration.pp

class mailman3::core::hyperkitty_integration (
  $config_name        = 'mailman-hyperkitty.cfg',
  $config_path        = "${mailman3::core::installroot}/mailman/${config_name}",
  $base_url           = 'http://localhost/hyperkitty/',
  $public_url         = 'http://lists.example.com/hyperkitty/',
  $hyperkitty_api_key = 'SecretArchiverAPIKey',
) {

  file { $config_name:
    ensure  => present,
    path    => "${config_path}/${config_name}",
    owner   => $mailman3::core::username,
    group   => $mailman3::core::groupname,
    mode    => '0600',
    content => template('mailman3/core/mailman-hyperkitty.cfg.erb'),
    notify  => Service['mailman3'],
  }

}
