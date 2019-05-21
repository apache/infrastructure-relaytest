# /etc/puppet/modules/svnqavm_pvm_asf/manifests/init.pp

class svnqavm_pvm_asf (

  # libapr is a build dependency of svn; moreutils provides chronic(1).
  $required_packages = ['libapr1-dev' , 'libaprutil1-dev', 'moreutils'],

){

# install required packages:
  package {
    $required_packages:
      ensure => 'present',
  }

  # manifest for svnqavm project vm

  user { 'svnsvn':
    ensure     => present,
    name       => 'svnsvn',
    comment    => 'svn role account',
    home       => '/home/svnsvn',
    managehome => true,
    system     => true,
  }

  user { 'wayita':
    ensure     => present,
    name       => 'wayita',
    comment    => 'wayita role account',
    home       => '/home/wayita',
    managehome => true,
    system     => true,
  }

  cron {
    'wayita-cron':
      command => '/home/wayita/bin/wayita-cron.sh',
      user    => 'wayita',
      hour    => 14,
      minute  => 23;

    # Run backport merges
    'backport-cron':
      command     => 'for i in 1.6.x 1.7.x 1.8.x 1.9.x 1.10.x 1.11.x 1.12.x; do cd && cd src/svn/$i && $SVN up -q --non-interactive && YES=1 MAY_COMMIT=1 ../trunk/tools/dist/backport.pl; done', # lint:ignore:140chars
      user        => 'svnsvn',
      hour        => 4,
      minute      => 0,
      environment => 'SVN=/usr/local/svn-current/bin/svn';
    # Log the revision of backport.pl in use.
    # (There's no log rotation since this will use about 2KB a year.)
    'backport-version-log':
      command     => '(date +\%Y\%m\%d: ; $SVNVERSION src/svn/trunk/tools/dist/backport.pl) >> ~/live-version.log',
      user        => 'svnsvn',
      hour        => 4,
      minute      => 0,
      environment => 'SVNVERSION=/usr/local/svn-current/bin/svnversion';

    'Update our Haxx-URL-to-Message-Id map':
      command     => 'cd ~/src/svn/site && ${SVN} up -q && tools/generate-message-id-map.py',
      user        => 'svnsvn',
      hour        => 4,
      minute      => 0,
      environment => 'SVN=/usr/local/svn-current/bin/svn';

    'Update our upcoming changes list':
      command     => 'cd ~/src/svn/1.11.x && chronic ~/src/svn/site/tools/generate-upcoming-changes-log.sh',
      user        => 'svnsvn',
      hour        => 4,
      minute      => 15,
      environment => 'SVN=/usr/local/svn-current/bin/svn';

  }

}
