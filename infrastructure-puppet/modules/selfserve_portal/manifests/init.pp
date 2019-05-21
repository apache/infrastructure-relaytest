#/etc/puppet/modules/selfserve_portal/manifests/init.pp

# selfserve class for the self service portal - jira,confluence,mail lists, git repo, moin
class selfserve_portal (

  # Below is in tools yaml

  $cliversion = '',

  # Below contained in eyaml

  $slackUrl = '',
  $jira_un  = '',
  $jira_pw  = '',
  $moin_user = '',
  $moin_pw = '',

){

  $deploy_dir    = '/var/www/selfserve-portal'
  $install_base  = '/usr/local/etc/'
  $atlassian_cli = "atlassian-cli-${cliversion}"
  $moin_dir      = "${install_base}/moin-to-cwiki"
  $uwc_dir       = "${moin_dir}/universal-wiki-converter"

file {
    $deploy_dir:
      ensure  => directory,
      recurse => true,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      source  => 'puppet:///modules/selfserve_portal/www',
      require => Package['apache2'];
    "${deploy_dir}/site/js/keys.json":
      ensure => file,
      owner  => 'root',
      group  => 'www-data',
      mode   => '0775';
    "${deploy_dir}/site/js/spacekeys.json":
      ensure => file,
      owner  => 'root',
      group  => 'www-data',
      mode   => '0775';
    "${install_base}/selfserve/":
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${install_base}/selfserve/queue":
      ensure => directory,
      owner  => 'www-data',
      group  => 'www-data',
      mode   => '0755';
    "${install_base}/selfserve/selfserve.yaml":
      content => template('selfserve_portal/selfserve.yaml.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';
    $moin_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    $uwc_dir:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${uwc_dir}/conf":
      ensure => directory,
      owner  => 'root',
      group  => 'www-data',
      mode   => '0775';
    "${uwc_dir}/populate-properties.sh":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/populate-properties.sh',
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${uwc_dir}/sync-moin-project.sh":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/sync-moin-project.sh',
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${uwc_dir}/sync-moin-all.sh":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/sync-moin-all.sh',
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${uwc_dir}/mv-FrontPage-to-Home.sh":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/mv-FrontPage-to-Home.sh',
      owner  => 'root',
      group  => 'root',
      mode   => '0755';
    "${uwc_dir}/exclude-list.txt":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/exclude-list.txt',
      owner  => 'root',
      group  => 'root',
      mode   => '0644';
    "${uwc_dir}/conf/confluenceSettings.properties.template":
      ensure  => present,
      content => template('selfserve_portal/confluenceSettings.properties.template.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644';
    "${uwc_dir}/conf/converter.moinmoin.properties.template":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/converter.moinmoin.properties.template',
      owner  => 'root',
      group  => 'root',
      mode   => '0644';
    "${uwc_dir}/conf/exporter.moinmoin.properties.template":
      ensure => present,
      source => 'puppet:///modules/selfserve_portal/exporter.moinmoin.properties.template',
      owner  => 'root',
      group  => 'root',
      mode   => '0644';

# Required scripts for cronjobs

    "${install_base}/${atlassian_cli}/jira-get-category.sh":
      content => template('selfserve_portal/jira-get-category.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
    "${install_base}/${atlassian_cli}/jira-get-workflows.sh":
      content => template('selfserve_portal/jira-get-workflows.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
    "${install_base}/${atlassian_cli}/jira-get-projects.sh":
      content => template('selfserve_portal/jira-get-projects.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
    "${install_base}/${atlassian_cli}/confluence-get-spaces.sh":
      content => template('selfserve_portal/confluence-get-spaces.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
    "${install_base}/${atlassian_cli}/jira.sh":
      content => template('selfserve_portal/jira.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
    "${install_base}/${atlassian_cli}/confluence.sh":
      content => template('selfserve_portal/confluence.sh.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0755';
  }

  file {
    "/root/.subversion":
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0750';
    "/root/.subversion/auth":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0750',
      require => File["/root/.subversion"];
    "/root/.subversion/auth/svn.simple":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0750',
      require => File["/root/.subversion/auth"];
    "/root/.subversion/auth/svn.simple/a46d7dd31d883fd4c3e388e6496a6ae5":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0640',
      content => template('wiki_asf/svn-credentials.erb'),
      require => File["/root/.subversion/auth/svn.simple"];
  }

# cronjobs

  cron {
'jira-get-category':
      user        => root,
      minute      => '30',
      command     => "${install_base}/${atlassian_cli}/jira-get-category.sh > /dev/null 2>&1",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh"; # lint:ignore:double_quoted_strings

'jira-get-workflows':
      user        => root,
      minute      => '32',
      command     => "${install_base}/${atlassian_cli}/jira-get-workflows.sh > /dev/null 2>&1",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh"; # lint:ignore:double_quoted_strings

'jira-get-projects':
      user        => root,
      minute      => '34',
      command     => "${install_base}/${atlassian_cli}/jira-get-projects.sh > /dev/null 2>&1",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh"; # lint:ignore:double_quoted_strings

'confluence-get-spaces':
      user        => root,
      minute      => '36',
      command     => "${install_base}/${atlassian_cli}/confluence-get-spaces.sh > /dev/null 2>&1",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh"; # lint:ignore:double_quoted_strings
'sync-moin-all':
      user        => root,
      minute      => '53',
      command     => "${uwc_dir}/sync-moin-all.sh > /dev/null 2>&1",
      environment => "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\nSHELL=/bin/sh"; # lint:ignore:double_quoted_strings
  }
}
