#!/usr/bin/perl
$list = "";
$num = 0;
while(<>) {
    chop;
    $list .= " $_";
    $num += 1;
    if ($num >= 30) {
	print "Adding $list\n";
	system("ezmlm-sub `pwd` $list\n");
	$num = 0;
	$list = "";
    }
}
print "Adding $list\n";
system("ezmlm-sub `pwd` $list\n");
