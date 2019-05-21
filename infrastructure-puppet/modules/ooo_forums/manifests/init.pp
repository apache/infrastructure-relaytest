#/etc/puppet/modules/ooo_forums/manifests/init.pp

class ooo_forums (

  $username      = 'phpbb',
  $groupname     = 'phpbb',
) {

  user {
    $username:
      ensure  => 'present',
      name    => $username,
      shell   => '/usr/local/bin/bash',
      require => Group[$groupname],
      system  => true,
  }

  group {
    $groupname:
      ensure => 'present',
      name   => $groupname,
      system => true,
  }

}
