class ulimit::install::ubuntu::1404 ( 
) { 

  file { '/etc/security/limits.conf':
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "puppet:///modules/ulimit/limits.${asfosname}-${asfosrelease}.conf",
  }

  ulimit::rule {
    'root-soft-nofile':
      ulimit_domain => 'root',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '8192';

    'root-hard-nofile':
      ulimit_domain => 'root',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '10240';

    'all-soft-nofile':
      ulimit_domain => '*',
      ulimit_type   => 'soft',
      ulimit_item   => 'nofile',
      ulimit_value  => '8192';

    'all-hard-nofile':
      ulimit_domain => '*',
      ulimit_type   => 'hard',
      ulimit_item   => 'nofile',
      ulimit_value  => '10240';
  }
}
