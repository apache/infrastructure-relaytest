#!/usr/bin/env perl -w

# Check the .archives file for duplicates etc.

use strict;
use Getopt::Long;

my %options;
my $order_check = 0;

Getopt::Long::Configure('bundling');
GetOptions(\%options,
           'o'  => \$order_check
           );


my $FILE='.archives';
open IN,"<",$FILE or die "Cannot open input file: $FILE $!\n";

my %names=();
my %paths=();
my $prev='';
my $section=1;

# These lists are private but don't contain one of the normally expected strings
my %private= map { $_ => 1 } qw(
audit
cloudstack-press
community-cfp-review
events-commits
ignite-ci
infra-commits
openoffice-forum-admin
operations
perl-conference
spamassassin-friends
tm-registrations
trafficserver-summits
);

while(<IN>){
	if (m!^\s*"([\w-]+)",\s+"(/[./\w-]+/)",\s*$!) {
		my ($name,$path) = ($1,$2);
		$names{$name}++;
		$paths{$path}++;
		if ($section > 2) {
			my $privateName = ($private{$name} || $name =~ /-private|-security$|-tck|-trademarks|^apachecon-(press|planners|rfp|speakers)/);
			my $privatePath = ($path =~ /(private|restricted)-arch/);
			if ($privateName != $privatePath) {
				print "Privacy mismatch: $_";
			}
		}
		if ($order_check && $section > 1 && $name lt $prev) {
			print "Sort order: $name should appear before $prev\n"
		}
		$prev=$name;
	} elsif (m!^$!){
		$section++;
		$prev='';
		next;
	} else {
		chomp;
		print "Unexpected line: '$_'\n";
	}
}
close IN;
for (sort keys %names) {
	print "Duplicated name: $_\n" if $names{$_} > 1;
}

for (sort keys %paths) {
	print "Duplicated path: $_\n" if $paths{$_} > 1;
}
print "Finished checking $FILE\n";
