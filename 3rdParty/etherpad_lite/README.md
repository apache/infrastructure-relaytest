# OpenStack Etherpad Lite Module

This module installs and configures Etherpad Lite

forked from openstack-infra/puppet-etherpad_lite

There are few changes made to this vs puppetizing, specifically the template and the removal of nodejs and npm install from the etherpad_lite base. 
nodejs and npm are both installed using base packages which was causing issues with runtime order and this module.
