#/etc/puppet/modules/mailman3/manifests/postorius/config.pp

# == Class mailman3::postorius::config
#
# == Parameters
#
# [*allowed_hosts*]
#  An array of strings representing the host/domain names that this Django
#  site can serve.
#
# [*db*]
#  What database type to use, valid options are: 'postgresql', 'mysql', or 'sqlite'.
#  Make sure to add any required system packages for the desired database type
#  to mailman3::postoirus::packages.
#  (i.e. postgres dev package, mysql client packages)
#
# [*dbhost*]
#  Hostname/IP of the database being used, Empty for localhost domain sockets,
#  127.0.0.1 for localhost through TCP.
#
# [*dbport*]
#  Port number of the database host, leave empty to use default port of chosen
#  database.
#
# [*dbname*]
#  Name of database to use (must be defined if not using sqlite).
#
# [*dbuser*]
#  username to connect to database with
#
# [*dbpass*]
#  Database user password to connect with
#
# [*debug*]
#  Turn on Django's debug mode. **DO NOT ENABLE ON PRODUCTION DEPLOYMENT**
#
# [*timezone*]
#  Local time zone for this installation. Choices can be found here:
#   http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
#  although not all choices may be available on all operating systems.
#
# [*language_code*]
#  Language code for this installation. All choices can be found here:
#   http://www.i18nguy.com/unicode/language-identifiers.html
#
# [*use_i18n*]
#  If you set this to False, Django will make some optimizations so as not
#  to load the internationalization machinery.
#
# [*mailman_api_url*]
#  URL (and port) that Mailman 3 is running on
#
# [*mailman_api_user*]
#  Username to connecto to Mailman 3 API
#
# [*mailman_api_password*]
#  Password to connect to Mailman 3 API
#
# [*postoirus_settings*]
#  Path to where the postorius settings file will be, defaulting filename is
#  local_settings.py. (make sure to edit any commands referencing settings(.py)
#  localsetings(.py)).
#
# [*secretkey*]
#  A secret key for a particular Django installation. This is used to provide
#  cryptographic signing, and should be set to a unique, unpredictable value.
#  **CHANGE THIS VALUE IN PRODUCTION**

class mailman3::postorius::config (
  $allowed_hosts = ['localhost'],
  $db = 'sqlite',
  $dbhost = '',
  $dbport = '',
  $dbname = undef,
  $dbuser = undef,
  $dbpass = undef,
  $debug = false,
  $timezone = 'America/Los_Angeles',
  $language_code = 'en-us',
  $use_i18n = true,
  $mailman_api_url = 'http://localhost:8001',
  $mailman_api_user = 'restadmin',
  $mailman_api_password = 'restpass',
  $postorius_settings = "${::mailman3::postorius::installroot}/postorius_standalone/local_settings.py",
  $secretkey = 'changeme',
) {

  validate_bool($debug)

  $backend = $db ? {
    'postgresql' => 'postgresql_psycopg2',
    'mysql'      => 'mysql',
    'sqlite'     => 'sqlite3',
    default      => undef,
  }

  if $backend == undef {
      fail("Invalid backend selected: ${db}\nValid options: mysql, postgresql, sqlite.")
  } elsif $backend != 'sqlite3' {
    if empty($dbname) or empty($dbuser) or empty($dbpass) {
      fail('not enough variables')
    }
  }

  $db_connector = $db ? {
    'postgresql' => 'psycopg2',
    'mysql'        => 'MySQL-python',
    default        => undef,
  }

  if $db_connector != undef {
    python::pip { "postorius_${db_connector}":
      ensure     => present,
      pkgname    => $db_connector,
      virtualenv => "${mailman3::postorius::installroot}/venv2",
      before     => Exec['postorius collectstatic'],
    }
  }

  file {
    $postorius_settings:
      ensure  => present,
      content => template('mailman3/postorius/local_settings.py.erb'),
      owner   => $apache::user,
      group   => $apache::group,
      notify  => Service['apache2'],
      require => File["${::mailman3::postorius::installroot}/postorius_standalone"],
  }
}
