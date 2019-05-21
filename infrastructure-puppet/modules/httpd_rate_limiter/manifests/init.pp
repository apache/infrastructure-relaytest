#/etc/puppet/modules/httpd_rate_limiter/manifests/init.pp

# requires mod_lua capable host (ubu >= 16.04)
# and httpd on the box, or it will ignore things.

class httpd_rate_limiter (
  $interval                 = '120',
  $cpumax                   = '60',
  $whitelist                = '',
  $whiteips                 = '',
  $autoconf                 = false,
  $asfilter                 = false,
){

  # Make sure we are using httpd here
  if defined(Class['apache']) {
    file {
      '/var/www/rate-limit.lua':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('httpd_rate_limiter/rate-limit.lua.erb');
    }
    # Autoconf means set up everything in this mod
    # if false, expect the node yaml to set it up.
    if $autoconf {
      # Check if mod_lua is loaded, if not, load it
      if !defined(Apache::Mod['lua']) {
          apache::mod { 'lua': }
      }
      # Add global rate-limit conf
      if $asfilter {
        apache::custom_config {
          'rate-limit':
            ensure   => present,
            filename => 'rate-limit.conf',
            content  => template('httpd_rate_limiter/rate-limit-asfilter.conf.erb'),
        }
      } else {
        apache::custom_config {
          'rate-limit':
            ensure   => present,
            filename => 'rate-limit.conf',
            content  => template('httpd_rate_limiter/rate-limit.conf.erb'),
        }
      }
    }
  }
}
