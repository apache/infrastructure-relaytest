# deploy rsync-offsite script

class rsync_asf (
  $scriptpath   = '/root/rsync-offsite.sh',
  $dumplist     = '/root/dumplist',

  # override fslist with array in yaml
  $fslist       = [ '/x1','/x2' ],

  # when to fire the rsync job
  $cron_hour    = '22',
  $cron_minute  = '10',

  # define the password in eyaml. add it to bai's rsync config also
  $rsync_passwd = '',
){

  python::pip {
    'datadog' :
      ensure => present;
      }
  # needed for join function
  include stdlib

  # stunnel dependency
  include stunnel_asf

  # pull in datadog api key from eyaml
  include datadog_agent

  file {
    'rsync-offsite.sh':
      ensure  => present,
      path    => $scriptpath,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template('rsync_asf/rsync-offsite.sh.erb');
    $dumplist:
      ensure  => present,
      path    => $dumplist,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => join($fslist,"\n");
    '/root/.pw-abi':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $rsync_passwd;
  }

  cron {
    'rsync offsite':
      command => "/usr/local/bin/dogwrap -n \"Running rsync backup\" -k ${datadog_agent::api_key} --submit_mode all \"${scriptpath}\"",
      user    => 'root',
      hour    => $cron_hour,
      minute  => $cron_minute,
  }

}
