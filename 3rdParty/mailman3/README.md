# mailman3
Puppet managed install of mailman3 components

This current version requires other puppet modules:

https://github.com/stankevich/puppet-python/ - at the time of writing this we suggest you stick with v1.9.4 - This is used to manage the pyvenv

https://github.com/stumped2/puppetlabs-apache - This is used to manage the apache (httpd) package. This version is a fork of the Pupeptlabs module, but with fixes for event_mpm 

