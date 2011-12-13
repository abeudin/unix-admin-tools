#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package sgids;

my $title         = "Files where Setgid is used";    # title of the test
my $security_test = "find / -perm -2000 -type f";    # the security test
my $exception_file =
  "conf/whitelists/sgids-whitelist.conf";          # the file with exceptions

# help - information about the check
my $help = <<HELP;
The following programs have the SGID set. This might
represent a security risk.
Learn more at http://buck-security.org/doc.html#c_sgids
HELP



# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
