#!/usr/bin/env perl

use strict;
use warnings;
use LWP;
use CGI::Carp qw(fatalsToBrowser);

my $user = 'preview';
my $site = 'https://blogs.apache.org';

open(C, "< .$user") or die "Unable to open handle to .$user: $!\n";
my $pass = <C>;
chomp $pass;
close C;

print "Content-Type: text/html\n\n";

my $browser = LWP::UserAgent->new;
$browser->cookie_jar( {} );
$browser->post("$site/roller_j_security_check", [ j_username => $user, j_password => $pass]);

my $uri = $ENV{REQUEST_URI};
my ($blog, $entry) = $uri =~ m,.*/([^/]+)/.previewEntry=(.+)$, or die "Unexpected REQUEST_URI \"$uri\"";

my $res = $browser->get("$site/roller-ui/authoring/preview/$blog/?previewEntry=$entry");

my $content = $res->content();

# munge the links and url paths
$content =~ s,href="/,href="$site/,g;
$content =~ s,/roller-ui/authoring/preview/([^ ]+.css),/$1,;

print $content;

