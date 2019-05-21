#! /usr/bin/perl -w
#
# aplists.pl [options] [list-parent-directory]
#
# -h    help/usage
# -c    count messages in last 24 hours
# -o    include public lists (subscription not moderated)
# -O    don't include public lists
# -p    include private lists (subscription moderated)
# -P    don't include private lists
# -a    include both public and private lists
# -x    Generate output in XML format
#
# Output format is one line per list:
#  <site>:<listname>[=<info-file>][,<listname>[=info-file]...
#
# or XML:
#  <mailing-lists>
#   <asof>yyyy-mm-dd</asof>
#   <site>
#    <name>sitename</name>
#    <list>
#     <name>listname</name>
#     <status>unknown|public|private</status>
#     <subscribers>int</subscribers>
#     <digest-subscribers>int</digest-subscribers>
#     <info>encoded-info</info>
#     <messages>int</messages>      <!-- optional -->
#    </list>
#    <list>...
#   </site>
#     :
#  </mailing-lists>
#
use strict;
use Getopt::Long;
use Symbol;
use POSIX;
#use XML::LibXML::Common qw(:encoding);

my %options;
my $include_public = 1;
my $include_private = 0;
my $use_xml = 0;
my $count = 0;
my $debug = 0;
my $phandle = gensym();

Getopt::Long::Configure('bundling');
GetOptions(\%options,
           'a'  => sub { $include_public = $include_private = 1; },
           'c'  => \$count,
           'd+' => \$debug,
           'h'  => \&usage,
           'o'  => \$include_public,
           'O'  => sub { $include_public = 0; },
           'p'  => \$include_private,
           'P'  => sub { $include_private = 0; },
           'x'  => \$use_xml,
           );

#
# No counting if we're not generating XML..
#
$count = 0 if ($count && (! $use_xml));

debug('public  =', $include_public);
debug('private =', $include_private);

my $tlh = gensym();
my $slh = gensym();

my $TLD = $ARGV[0] || '/home/coar/apache-apmail/lists';
opendir($tlh, $TLD) or die("Can't opendir($TLD): $!");
my @tldirs = readdir($tlh);
closedir($tlh);

#
# @tldirs now has a list of all the sites.  Scan each one for the
# lists on that site.
#
my %lists;
for my $tldir (@tldirs) {
    next if ($tldir !~ /\w\.\w+$/i);
    next if (! -d "$TLD/$tldir");
    opendir($slh, "$TLD/$tldir") or die("Can't opendir($TLD/$tldir): $!");
    my @sldirs = readdir($slh);
    closedir($slh);
    for my $sldir (@sldirs) {
        next if ($sldir =~ /^(?:\.+|cvs)$/i);
        next if (! -d "$TLD/$tldir/$sldir");
        push(@{$lists{$tldir}}, $sldir);
    }
}
if ($use_xml) {
    print "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        . "<mailing-lists>\n";
    print ' <asof>' . strftime('%Y-%m-%d', localtime()) . "</asof>\n";
}
my $ifile = gensym();
for my $site (sort(keys(%lists))) {
    if ($use_xml) {
        print " <site>\n"
            . "  <name>$site</name>\n";
    }
    else {
        print "$site:";
    }
    my $continue = 0;
    for my $list (sort(@{$lists{$site}})) {
        my $is_archived;
        my $cmd;
        #
        # Assume the list is public in case we can't figure it out.
        #
        my $public = 1;
        my $is_digested = 1;
        my $config = "$TLD/$site/$list/config";
        if (open(CONFIG, "< $config")) {
            while (<CONFIG>) {
                if (/^F:/) {
                    debug(2, "found config line for $list\@$site: $_");
                    $public = ($_ =~ /S/);
                    $is_archived = ($_ =~ /a/);
                    $is_digested = ($_ =~ /d/);
                    last;
                }
            }
            close(CONFIG);
        }
        debug(3, "$list\@$site is " . ($public ? '' : 'not ') . 'public');
        debug(3, "$list\@$site is " . ($is_archived ? '' : 'not ') . 'archived');
        next if (($public && (! $include_public))
                 || ((! $public)  && (! $include_private)));
        if ($continue) {
            if (! $use_xml) {
                print ',';
            }
        }
        if ($use_xml) {
            print "  <list>\n"
                . "   <name>$list</name>\n"
                . '   <status>'
                . ($public ? 'public' : 'private')
                . "</status>\n";
        }
        else {
            print $list;
        }
        my $info = "$TLD/$site/$list/text/info";
        if (-r $info) {
            if ($use_xml) {
                open($ifile, "< $info");
                my @slurp = <$ifile>;
                close($ifile);
                my $slurp = join('', @slurp);
                if ($slurp !~ /^No information has been provided /) {
                    $slurp = utf8_safe($slurp);
#                    $slurp = encodeToUTF8('ISO-8859-1', $slurp);
                    chomp($slurp);
                    print "   <info>\n"
                        . "<![CDATA[$slurp]]>\n"
                        . "   </info>\n";
                }
            }
            else {
                print "=$info";
            }
        }
        $cmd = "ezmlm-list -n $TLD/$site/$list |";
        open($phandle, $cmd)
            and do {
                my $subs = <$phandle>;
                close($phandle);
                $subs =~ /(\d+)/;
                $subs = $1;
                print "   <subscribers>$subs</subscribers>\n";
            };
        if ($is_digested) {
            $cmd = "ezmlm-list -n $TLD/$site/$list/digest |";
            open($phandle, $cmd)
                and do {
                    my $subs = <$phandle>;
                    close($phandle);
                    $subs =~ /(\d+)/;
                    $subs = $1;
                    print '   <digest-subscribers>'
                        . $subs
                        . "</digest-subscribers>\n";
                };
        }
        if ($count) {
            my $msgs = -1;
            if ($is_archived) {
                $cmd = "find $TLD/$site/$list/archive "
                    . "-mtime -1 -type f -name '[0-9]*' "
                    . '| wc -l |';
                debug(2, $cmd);
                open($phandle, $cmd)
                    and do {
                        $msgs = <$phandle>;
                        close($phandle);
                        chomp($msgs);
                        debug(3, "msgs = '$msgs'");
                        $msgs =~ /(\d+)/;
                        $msgs = $1;
                    };
            }
            print "   <messages>$msgs</messages>\n";
        }
        my $ph = gensym();
        my $mods = '';
        $cmd = "ezmlm-list $TLD/$site/$list/mod |";
        debug(2, $cmd);
        open($ph, $cmd)
            and do {
                my @mods = <$ph>;
                close($ph);
                chomp(@mods);
                $mods = join(' ', @mods);
                debug(3, "mods = '$mods'");
            };
        if ($mods) {
            $mods = utf8_safe($mods);
#            $mods = encodeToUTF8('ISO-8859-1', $mods);
            print "   <moderators><![CDATA[$mods]]></moderators>\n";
        }
        if ($use_xml) {
            print "  </list>\n";
        }
    }
    if ($use_xml) {
        print " </site>\n";
    }
    else {
        print "\n";
    }
}
if ($use_xml) {
    print "</mailing-lists>\n";
}
#
# Help display
#
sub usage {
    print STDERR "Usage: $0 [-ahpP] [list-parent]\n"
        . "  -a  Include both public and private lists\n"
        . "  -h  This message\n"
        . "  -o  Include open (public) lists (default)\n"
        . "  -O  Do not include open lists\n"
        . "  -p  Include closed (private) lists\n"
        . "  -P  Do not include closed lists (default)\n";
    exit(0);
}

sub debug {
    my $level = 1;
    if ($_[0] =~ /^\d+$/) {
        $level = shift;
    }
    if ($debug >= $level) {
        print 'debug: ' . join(' ', @_) . "\n";
    }
}

sub utf8_safe {
    my ($input) = @_;
    my %table;
    my $ichar;
    for (my $i = 0; $i <= 0xFF; $i++) {
        $ichar = chr($i);
        if (($i == 0x09)
            || ($i == 0x0A)
            || ($i == 0x0D)
            || (($i >= 0x20)
                && ($i <= 0x7F))) {
            $ichar = chr($i);
#            if ($ichar eq '<') {
#                $table{$ichar} = '&lt;';
#            }
#            elsif ($ichar eq '>') {
#                $table{$ichar} = '&gt;';
#            }
#            elsif ($ichar eq '&') {
#                $table{$ichar} = '&amp;';
#            }
            next;
        }
        if (($i < 0x7F)
            || (($i >= 0x7F) && ($i <= 0x84))
            || (($i >= 0x86) && ($i <= 0x9F))) {
            $table{$ichar} = '*';
        }
        else {
            $table{$ichar} = sprintf('&#x%02x;', $i);
        }
    }
    my $output = '';
    for (my $i = 0; $i < length($input); $i++) {
        my $ichar = substr($input, $i, 1);
        if (defined($table{$ichar})) {
            $output .= $table{$ichar};
        }
        else {
            $output .= $ichar;
        }
    }
    return $output;
}

#
# Local Variables:
# mode: cperl
# tab-width: 4
# indent-tabs-mode: nil
# End:
#
