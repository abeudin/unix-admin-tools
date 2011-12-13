#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package worldwriteabledirs;

my $title = "World Writeable Directories";    # title of the test
my $security_test =
  "find / -type d -perm -o+w 2> /dev/null";    # the security test
my $exception_file = "conf/whitelists/worldwriteabledirs-whitelist.conf";  # the file with exceptions

# help - information about the check
my $help = <<HELP;
The following directories are writeable for all users.
Learn more at http://buck-security.org/doc.html#c_wwd
HELP

# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
