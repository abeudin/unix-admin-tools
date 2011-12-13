#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package superusers;

my $title         = "Find superusers";      # title of the test
my $security_test = 'grep \':00*:\' /etc/passwd | awk -F: \'{print $1}\'';    # the security test
my $exception_file =
  "conf/whitelists/superusers-whitelist.conf";    # the file with exceptions

# help - information about the check
my $help = <<HELP;
The following users have administrator rights.
Learn more at http://buck-security.org/doc.html#c_su
HELP

# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
