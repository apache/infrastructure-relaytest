# Class: rsync::server
#
# The rsync server. Supports both standard rsync as well as rsync over ssh
#
# Requires:
#   class xinetd if use_xinetd is set to true
#   class rsync
#
class rsync::server(
  $use_xinetd = true,
  $address    = '0.0.0.0',
  $motd_file  = 'UNSET',
  $use_chroot = 'yes',
  $uid        = 'nobody',
  $gid        = 'nobody',
  $log_dir   = '/var/log/rsync',
  $service_ensure = 'running',
  $rsync_enable = true,
  $rsync_opts = '',
  $rsync_nice = '',
) inherits rsync {

  $conf_file = $::osfamily ? {
    'Debian' => '/etc/rsyncd.conf',
    'suse'   => '/etc/rsyncd.conf',
    default  => '/etc/rsync.conf',
  }
  $servicename = $::osfamily ? {
    'suse'  => 'rsyncd',
    default => 'rsync',
  }

  file { 'rsync log folder':
    ensure => directory,
    path   => $log_dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }


  if $use_xinetd {
    include xinetd
    xinetd::service { 'rsync':
      bind        => $address,
      port        => '873',
      server      => '/usr/bin/rsync',
      server_args => "--daemon --config ${conf_file}",
      require     => Package['rsync'],
    }
  } else {
    
    service { $servicename:
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      subscribe  => Concat[$conf_file],
    }

    if ( $::osfamily == 'Debian' ) {
      file { '/etc/default/rsync':
        content => template('rsync/defaults.erb'),
        notify  => Service['rsync'],
      }
    }
  }

  if $motd_file != 'UNSET' {
    file { '/etc/rsync-motd':
      source => 'puppet:///modules/rsync/motd',
    }
  }

  concat { $conf_file: }

  # Template uses:
  # - $use_chroot
  # - $address
  # - $motd_file
  concat::fragment { 'rsyncd_conf_header':
    target  => $conf_file,
    content => template('rsync/header.erb'),
    order   => '00_header',
  }

}
