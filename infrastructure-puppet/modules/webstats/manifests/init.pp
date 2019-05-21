#/etc/puppet/modules/webstats/manifests/init.pp

class webstats (
){
  
  file {
    '/usr/local/etc/webstats.py':
      ensure => file,
      mode   => '0755',
      owner  => 'www-data',
      group  => 'www-data',
      source => 'puppet:///modules/webstats/webstats.py';
    '/var/www/snappy/domains.txt':
      ensure => file,
      mode   => '0755',
      owner  => 'www-data',
      group  => 'www-data',
      source => 'puppet:///modules/webstats/webstats-domains.txt';
  }

  cron {
    'run-webstats':
      user        => 'www-data',
      minute      => '0',
      hour        => '*/12',
      command     => "cd /usr/local/etc && python webstats.py > /dev/null",
      environment => [
        'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
        'SHELL=/bin/sh'
      ];
  }
}
