#/etc/puppet/modules/mysql_asf/manifests/backup.pp


class mysql_asf::backup (
  $script_path   = '/root',
  $script_name   = 'dbsave_mysql.sh',
  $hour          = 03,
  $minute        = 45,
  $dumproot      = '/x1/db_dump/mysql',
  $age           = '5d',
  $rsync_offsite = 'false', # copy to bai if true, requires setup
  $rsync_user    = 'apb-mysql',
  $rsync_passwd  = '', # set in eyaml if rsync_offsite
) {

  require stunnel_asf
  require mysql::server

  python::pip {
    'datadog' :
      ensure => present;
      }

  # pull in datadog api key from eyaml
  include datadog_agent

  file {
    'dbsave.sh':
      path    => "${script_path}/${script_name}",
      owner   => 'root',
      group   => 'root',
      mode    => '0744',
      content => template('mysql_asf/dbsave_mysql.sh.erb'),
  }

  if $rsync_offsite == 'true' {
    file {
      '/root/rsynclogs':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0700';
      '/root/.pw-abi':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => $rsync_passwd;
      }
  }

  tidy { 'mysql-dumps':
    path    => $dumproot,
    age     => $age,
    recurse => true,
    matches => ['*.sql.gz'],
  }

  cron { 'mysql-dump-rsync-to-abi':
    hour    => $hour,
    minute  => $minute,
    command => "/usr/local/bin/dogwrap -n \"Running rsync backup\" -k ${datadog_agent::api_key} --submit_mode all \"${script_path}/${script_name}\"", # lint:ignore:140chars
  }
}
