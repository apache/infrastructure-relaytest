#/etc/puppet/modules/ssh/manifests/userkeys.pp

class ssh::userkeys (

  $keycontent  = '',
  $sshkeysdir  = '',
  $user        = '',

) { file {"${sshkeysdir}/${user}.pub":
    content  => $keycontent,
    owner    => $user,
    group    => root,
    mode     => '0640',
    require  => File["${sshdkeysdir}"],
  }
}
