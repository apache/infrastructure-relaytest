# /etc/puppet/modules/jenkins_slaves/manifests/multipy.pp

class build_slaves::multipy (
  $required_packages = [
    'python3.5',
    'python3.6',
    'python3.7',
    ],
  ){

  apt::ppa { 'ppa:deadsnakes/ppa':
    ensure => present,
  }
  ~> package {
      $required_packages:
        ensure  => 'latest',
        require => Class[apt::update],
  }
}

