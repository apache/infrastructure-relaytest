#/etc/puppet/modules/manifests/ssl/name/netbeans_org.pp

class ssl::name::netbeans_org (

  $sslcertcontents     = '',
  $sslcertname         = 'netbeans.org.crt',
  $sslchaincontent     = '',
  $sslchainname        = 'netbeans.org.chain',
  $sslkeycontents      = '',
  $sslkeyname          = 'netbeans.org.key',
  $sslrootdir          = '/etc/ssl',
  $sslrootdirgroup     = 'root',
  $sslrootdirowner     = 'root',
  $sslrootdirumask     = '0755',
) {

  if !defined(File["${sslrootdir}"]) {
    file {
      "${sslrootdir}":
        ensure => directory,
        group  => 'root',
        owner  => 'root',
        mode   => '0755';
      "${sslrootdir}/certs":
        ensure => directory,
        group  => 'root',
        owner  => 'root',
        mode   => '0755';
      "${sslrootdir}/private":
        ensure => directory,
        group  => 'root',
        owner  => 'root',
        mode   => '0700';
      }
  }

  file {
    "${sslrootdir}/certs/${sslcertname}":
      ensure  => present,
      require => File[$sslrootdir],
      content => $sslcertcontents,
      owner   => $sslrootdirowner,
      group   => $sslrootdirgroup;
    "${sslrootdir}/private/${sslkeyname}":
      ensure  => present,
      require => File[$sslrootdir],
      content => $sslkeycontents,
      owner   => $sslrootdirowner,
      group   => $sslrootdirgroup;
    "${sslrootdir}/certs/${sslchainname}":
      ensure  => present,
      require => File[$sslrootdir],
      content => $sslchaincontent,
      owner   => $sslrootdirowner,
      group   => $sslrootdirgroup;
  }
}
