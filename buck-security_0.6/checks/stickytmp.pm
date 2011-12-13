#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package stickytmp;

my $title = "Sticky-Bit set for /tmp";    # title of the test
my $security_test =
  'ls -ld /tmp | awk \'{print $1":"$3":"$4}\'';    # the security test
my $exception_file =
  "conf/whitelists/stickytmp-whitelist.conf";    # the file with exceptions
# help - information about the check
my $help = <<HELP;
The permission mode of your /tmp directory isn't secure.
Learn more at http://buck-security.org/doc.html#c_tmp
HELP




# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
