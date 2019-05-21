#/etc/puppet/modules/jira-slack-bridge/manifests/init.pp

class jira_slack_bridge (
  $service_name   = 'jira-slack-bridge',
  $shell          = '/bin/bash',
  $service_ensure = 'running',
  $username       = 'root',
  $group          = 'root',
  $slacktoken     = '',
  $jirauser       = '',
  $jirapass       = ''
) {
    # dir and py script
    file {
      '/usr/local/etc/jira-slack-bridge':
        ensure => directory,
        mode   => '0755',
        owner  => $username,
        group  => $group;
      '/var/run/jira-slack-bridge':
        ensure => directory,
        mode   => '0755',
        owner  => $username,
        group  => $group;
      '/usr/local/etc/jira-slack-bridge/slackbridge.yaml':
        mode    => '0755',
        owner   => $username,
        group   => $group,
        source => "puppet:///modules/jira_slack_bridge/slackbridge.yaml";
      '/usr/local/etc/jira-slack-bridge/jira-slack-bridge.py':
        mode    => '0755',
        owner   => $username,
        group   => $group,
        content => template('jira_slack_bridge/jira-slack-bridge.py.erb');
    }
    # Set up systemd on first init
    -> file {
      '/lib/systemd/system/jira-slack-bridge.service':
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
        source => "puppet:///modules/jira_slack_bridge/jira-slack-bridge.${::asfosname}";
    }
    -> exec { 'jsb-systemd-reload':
      command     => 'systemctl daemon-reload',
      path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
      refreshonly => true,
    }
    # Ensure, after systemd set up, that JSB is running
    -> service { $service_name:
        ensure    => $service_ensure,
        subscribe => [
          File['/usr/local/etc/jira-slack-bridge/slackbridge.yaml'],
          File['/usr/local/etc/jira-slack-bridge/jira-slack-bridge.py']
        ]
    }
}
