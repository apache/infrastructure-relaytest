# postfix_server_asf

# this class exists only to prevent hermes-vm from installing postfix
# unlike every other ubuntu host. it could easily be extended later if 
# there are other one-off machines which can't run postfix.

# hermes-vm is a legacy qmail server, and the ubuntu postfix packages 
# break qmail

class postfix_server_asf {

  if $::hostname !~ /hermes-vm/ {
    include postfix::server
  }

}


