#/etc/puppet/modules/mailman3/manifests/core/config.pp

# == Class mailman3::core::config
#
# === Parameters 
#
# ( As this list is so long it has been alpha sorted, to hopefully make it easier parse with the naked eye)
#
# [*archivedir*]
#  Directory for archive backends to store their messages in.  Archivers should
#  create a subdirectory in here to store their files.
#
# [*bindir*]
#  This is the directory containing the Mailman 'runner' and 'master' commands
#  if set to the string '$argv', it will be taken as the directory containing
#  the 'mailman' command.
#
# [*datadir*]
#  Directory for system-wide data.
#
# [*defaultlanguage*]
#  The default language for this server.
#
# [*devmodeenabled*]
# Setting enabled to true enables certain safeguards and other behavior
# changes that make developing Mailman easier.  For example, it forces the
# SMTP RCPT TO recipients to be a test address so that no messages are
# accidentally sent to real addresses.
#
# [*devmoderecipient*]
# Set this to an address to force the SMTP RCPT TO recipents when devmode is
# enabled.  This way messages can't be accidentally sent to real addresses.
#
# [*devmodetesting*]
# This gets set by the testing layers so that the runner subprocesses produce
# predictable dates and times.
#
# [*devmodewait*]
# Time-outs for starting up various test subprocesses, such as the LMTP and
# REST servers.  This is only used for the test suite, so if you're seeing
# test failures, try increasing the wait time.
#
# [*emailcmdsmaxlines*]
#  Mail command processor will ignore mail command lines after designated max.
#
# [*etcdir*]
#  Directory for configuration files and such.
#
# [*extdir*]
#  Directory containing Mailman plugins.
#
# [*layout*]
#  Which paths.* file system layout to use.
#
# [*listdatadir*]
#  All list-specific data.
#
# [*lockdir*]
#  Directory for system-wide locks.
#
# [*lockfile*]
#  Lock file.
#
# [*logdir*]
#  Directory where log files go.
#
# [*messagesdir*]
#  Directory where the default IMessageStore puts its messages.
#
# [*noreplyaddress*]
#  This is the local-part of an email address used in the From field whenever a
#  message comes from some entity to which there is no natural reply recipient.
#  Mailman will append '@' and the host name of the list involved.  This
#  address must not bounce and it must not point to a Mailman process.
#
# [*pendingrequestlife*]
#  Default length of time a pending request is live before it is evicted from
#  the pending database.
#
# [*pidfile*]
#  This is where PID file for the master runner is stored.
#
# [*posthook*]
#  A callable to run with no arguments late in the initialization process.
#  This runs after adapters are initialized.
#
# [*prehook*]
#  A callable to run with no arguments early in the initialization process.
#  This runs before database initialization.
#
# [*preservefiliteredmime*]
#  Can MIME filtered messages be preserved by list owners?
#
# [*queuedir*]
#  This is where the Mailman queue files directories will be created.
#
# [*senderheaders*]
#  Membership tests for posting purposes are usually performed by looking at a
#  set of headers, passing the test if any of their values match a member of
#  the list.  Headers are checked in the order given in this variable.  The
#  value From_ means to use the envelope sender.  Field names are case
#  insensitive.  This is a space separate list of headers.
#
# [*siteowner*]
#  This address is the "site owner" address.  Certain messages which must be
#  delivered to a human, but which can't be delivered to a list owner (e.g. a
#  bounce from a list owner), will be sent to this address.  It should point to
#  a human.
#
# [*templatedir*]
#  Root directory for site-specific template override files.
#
# [*vardir*]
#  This is the root of the directory structure that Mailman will use to store
#  its run-time data.
#


class mailman3::core::config (
  $antispamheaderchecks      = '',
  $antispamjumpchain         = 'hold',
  $archivedir                = '$var_dir/archives',
  $bindir                    = '$argv',
  $db                        = 'sqlite',
#  $databaseclass            = 'mailman.database.sqlite.SQLiteDatabase',
  $databasedebug             = 'no',
  $databaseurl               = 'sqlite:///$DATA_DIR/mailman.db',
  $datadir                   = '$var_dir/data',
  $defaultlanguage           = 'en',
  $devmodenabled             = 'no',
  $devmoderecipient          = '',
  $devmodetesting            = 'no',
  $devmodewait               = '60s',
  $emailcmdsmaxlines         = '10',
  $etcdir                    = '$var_dir/etc',
  $extdir                    = '$var_dir/ext',
  $languageaddon_enabled     = 'True', # This needs to be enabled for any of the lang packs below to work.
  $languageaddon_ar          = 'True',
  $languageaddon_ast         = 'True',
  $languageaddon_ca          = 'True',
  $languageaddon_cs          = 'True',
  $languageaddon_da          = 'True',
  $languageaddon_de          = 'True',
  $languageaddon_el          = 'True',
  $languageaddon_es          = 'True',
  $languageaddon_et          = 'True',
  $languageaddon_eu          = 'True',
  $languageaddon_fi          = 'True',
  $languageaddon_fr          = 'True',
  $languageaddon_gl          = 'True',
  $languageaddon_he          = 'True',
  $languageaddon_hr          = 'True',
  $languageaddon_hu          = 'True',
  $languageaddon_ia          = 'True',
  $languageaddon_it          = 'True',
  $languageaddon_jp          = 'True',
  $languageaddon_kr          = 'True',
  $languageaddon_lt          = 'True',
  $languageaddon_nl          = 'True',
  $languageaddon_no          = 'True',
  $languageaddon_pl          = 'True',
  $languageaddon_pt          = 'True',
  $languageaddon_ptbr        = 'True',
  $languageaddon_ro          = 'True',
  $languageaddon_ru          = 'True',
  $languageaddon_sk          = 'True',
  $languageaddon_sl          = 'True',
  $languageaddon_sr          = 'True',
  $languageaddon_sv          = 'True',
  $languageaddon_tr          = 'True',
  $languageaddon_uk          = 'True',
  $languageaddon_vi          = 'True',
  $languageaddon_zhcn        = 'True',
  $languageaddon_zhtw        = 'True',
  $languagemastercharset     = 'us-ascii',
  $languagemasterdescription = 'English (USA)',
  $languagemasterenabled     = 'yes',
  $layouts                   = 'local',
  $listdatadir               = '$var_dir/lists',
  $lockdir                   = '$var_dir/locks',
  $lockfile                  = '$lock_dir/master.lck',
  $logdir                    = '$var_dir/logs',
  $loggingbouncelevel        = 'info',
  $loggingbouncepath         = 'bounce.log',
  $loggingdatabaselevel      = 'warn',
  $loggingdatabasepath       = 'database.log',
  $loggingdebuglevel         = 'info',
  $loggingdebugpath          = 'debug.log',
  $loggingsmtplevel          = 'info',
  $loggingsmtpmsgevery       = '$msgid smtp to $listname for $recip recips, completed in $time seconds',
  $loggingsmtpmsgfailure     = '$msgid delivery to $recip failed with code $smtpcode, $smtpmsg',
  $loggingsmtpmsgrefused     = '$msgid post to $listname from $sender, $size bytes, $refused failures',
  $loggingsmtpmsgsuccess     = '$msgid post to $listname from $sender, $size bytes',
  $loggingsmtppath           = 'smtp.log',
  $loggingtemplateformat     = '%(asctime)s (%(process)d) %(message)s',
  $loggingtemplatedatefmt    = '%b %d %H:%M:%S %Y',
  $loggingtemplatepropagate  = 'no',
  $loggingtemplatelevel      = 'info',
  $loggingtemplatepath       = 'mailma.log',
  $mailmancfgfile            = '/etc/mailman.cfg',
  $masterclass               = 'mailman.core.runner.Runner',
  $masterinstances           = '1',
  $mastermaxrestarts         = '10',
  $masterpath                = '$QUEUE_DIR/$name',
  $mastersleeptime           = '1s',
  $masterstart               = 'yes',
  $messagesdir               = '$var_dir/messages',
  $mtaincoming               = 'mailman.mta.postfix.LMTP',
  $mtalmtphost               = '127.0.0.1',
  $mtalmtpport               = '8024',
  $mtadeliveryretryperiod    = '5d',
  $mtamaxrecipients          = '500',
  $mtamaxdeliverythreads     = '0',
  $mtamaxsessionsperconnect  = '0',
  $mtaoutgoing               = 'mailman.mta.deliver.deliver',
  $mtasmtphost               = 'localhost',
  $mtasmtpport               = '25',
  $mtasmtpuser               = '',
  $mtasmtppass               = '',
  $noreplyaddress            = 'noreply', # See comment at the top for usage instructions.
  $passwordconfig            = 'python:mailman.config.passlib',
  $passwordlength            = '8',
  $pendingrequestlife        = '3d',
  $pidfile                   = '/var/run/mailman/master.pid',
  $posthook                  = '',
  $prehook                   = '',
  $preservefiliteredmime     = 'no',
  $queuedir                  = '$var_dir/queue',
  $senderheaders             = 'from from_ reply-to sender',
  $siteowner                 = 'root@localhost', # Set a default address that should be safe.
  $templatedir               = '$var_dir/templates',
  $vardir                    = '/var/tmp/mailman',
  $webservicehostname        = 'localhost',
  $webserviceport            = '8001',
  $webserviceusehttps        = 'no',
  $webserviceshowtracebacks  = 'yes',
  $webserviceapiversion      = '3.0',
  $webserviceadminuser       = 'restadmin',
  $webserviceadminpass       = 'restpass',
  $custom_config             = '',




) {

  $databaseclass = $db ? {
    'postgresql' => 'mailman.database.postgresql.PostgreSQLDatabase',
    'sqlite'     => 'mailman.database.sqlite.SQLiteDatabase',
    default      => undef,
  }

  if $databaseclass == undef {
      fail("Invalid backend selected: ${db}\nValid options: postgresql or sqlite.")
  }

  $db_connector = $db ? {
    'postgresql' => 'psycopg2',
    default        => undef,
  }

  if $db_connector != undef {
    python::pip { "core_${db_connector}":
      ensure     => present,
      pkgname    => $db_connector,
      virtualenv => "${mailman3::core::installroot}/venv3",
      notify     => Service['mailman3'],
    }
  }

  file {
    $mailmancfgfile:
      ensure  => present,
      content => template('mailman3/core/mailman.cfg.erb'),
      owner   => $::mailman3::core::username,
      group   => $::mailman3::core::groupname,
      mode    => '0600',
      notify  => Service['mailman3'];
  }

}
