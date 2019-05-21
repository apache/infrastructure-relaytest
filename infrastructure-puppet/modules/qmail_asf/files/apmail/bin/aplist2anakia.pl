#! /usr/bin/perl -w
#
# Script to turn the mailing-list data (from aplists.pl) into an Anakia page for
# building into the Apache site.
#
use strict;
use HTML::Entities;

print "<?xml version=\"1.0\"?>\n"
    . "<document>\n"
    . "  <properties>\n"
    . "    <title>Apache Software Foundation Mailing Lists</title>\n"
    . "  </properties>\n"
    . "  <body>\n";
for my $line (<>) {
    chomp($line);
    my ($site, $lists) = split(/:/, $line, 2);
    print "    <section id=\"$site\">\n"
        . "      <title>Mailing Lists for $site</title>\n";
    if (! $lists) {
        print "      <p>No known lists.</p>\n";
        next;
    }
    my @lists = split(/,/, $lists);
    for my $ldata (@lists) {
        my ($list, $info) = split(/=/, $ldata);
        print "      <section id=\"$list\@$site\">\n"
            . "        <title>$list\@$site</title>\n";
        if ($info && (-r $info)) {
            open(INFO, "< $info");
            my @info = <INFO>;
            close(INFO);
            my $info = join('', @info);
            $info =~ s!<#l#>!$list!gms;
            $info = encode_entities($info);
            $info =~ s!\n\n\n!\n\n!gms;
            $info =~ s!\n\n!\n</p>\n<p>\n!gms;
            print "        <p>\n$info        </p>\n";
        }
        else {
            print "        <p>No information available about this list.</p>\n";
        }
        print "      </section>\n";
    }
    print "    </section>\n";
}
print "  </body>\n"
    . "</document>\n";
