#!/usr/bin/perl

# Fix the archives when archivealiasmonthly failed to run.

# This file is dangerous, so it has been disabled by default.
# To enable, copy to another file, add the directories to the todo list,
# change the month named 200503 to the one that needs to be split, and
# uncomment the last system call if needed.

# This script assumes that the .qmail files on minotaur all point
# to last month's archive file and none of the current month files
# exist within the directories given in the todo list (below).

# The todo list needs to be generated first, e.g. on minotaur
# 
#  cd /home/apmail
#  find /home/apmail/public-arch -name 200503 -print > temp1
#  find /home/apmail/private-arch -name 200503 -print >> temp1
#  vi temp1
#  :g/\/200503/s//",/g
#  :g/^/s//    "/g
#
# and then insert temp1 into the array below named todo.

# For safety reasons, this script leaves the old month files
# in each directory, named old.YYYYMM, so that you can check
# the new files manually before removing the old ones.


$lhome = '/home/apmail';

@todo = (
#   "/home/apmail/roy",   # a list of archive directories
);

print "Halting e-mail deliveries with chmod +t $lhome\n";
chmod 01755, $lhome;

foreach my $dir (@todo) {
    print $dir, "\n";
    chdir $dir || die "unable to cd $dir, $!\n";
    system "/bin/mv 200503 old.200503";
    system "$lhome/bin/split-from-month.pl old.200503";
}

# system "/usr/bin/perl -pi -e 's/200503/200504/;' $lhome/.qmail-*-archive";

print "Restoring e-mail deliveries with chmod -t $lhome\n";
chmod 0755, $lhome;

exit 0;
