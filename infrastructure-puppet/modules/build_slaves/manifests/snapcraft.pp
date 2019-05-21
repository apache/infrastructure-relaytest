#/etc/puppet/modules/build_slaves/manifests/snapcraft.pp

# Class to install Snapcraft via the snapd package manager.
# For now, limit this class to 16.04.x LTS nodes
# This class is included via data/roles/jenkins.yaml

class build_slaves::snapcraft (

  $username = $build_slaves::jenkins::username,
  $group    = 'lxd',

  ) {

require build_slaves

case $::lsbdistrelease {
  16.04: {
  file {
    "/home/${username}/lxd-preseed.yaml":
    ensure => file,
    source => 'puppet:///modules/build_slaves/lxd-preseed.yaml',
  }

  exec { 'install_snapcraft':
    command => 'snap install snapcraft --classic',
    path    => '/usr/bin',
    user    => 'root',
    creates => '/snap/bin/snapcraft',
    timeout => 600,
    require => Package['snapd'];
  }

  -> exec { 'install_lxd':
    command => 'snap install lxd',
    path    => '/usr/bin',
    user    => 'root',
    creates => '/snap/bin/lxd',
    timeout => 600;
  }

  -> exec { 'chown_lxd':
    command     => "newgrp ${group} && usermod -aG ${group} ${username}",
    path        => ['/usr/bin', '/usr/sbin',],
    user        => 'root',
    timeout     => 600,
    refreshonly => true,
    require     => [Exec['install_lxd'],User[$username]];
  }

  -> exec { 'init_lxd':
    command     => 'lxd init --preseed < lxd-preseed.yaml',
    path        => '/snap/bin',
    cwd         => "/home/${username}",
    user        => $username,
    refreshonly => true,
    require     => [Exec['chown_lxd'],User[$username]];
  }
}
  default: {
      warning("ASF Module snapcraft is not supported on ${::lsbdistrelease}")
    }
  }
}

