#/environments/windows/modules/datadog_agent/manifests/init.pp

class datadog_agent (
  $api_key = '',
){

  file { 'c:\temp':
    ensure => 'directory',
  }

  # download DD agent version 5.29.0
  download_file { 'Download datadog agent' :
    url                   => 'https://s3.amazonaws.com/ddagent-windows-stable/ddagent-cli-5.29.0.msi',
    destination_directory => 'c:\temp',
  }

  package { 'ddagent-cli-latest.msi' :
    ensure          => '5.29.0.1',
    source          => 'c:\temp\ddagent-cli-5.29.0.msi',
    install_options => ["APIKEY=${api_key}"],
  }
}
