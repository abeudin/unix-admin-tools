#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package !PACKAGENAME;

my $title         = "TODO_TITLE";      # title of the test
my $security_test = "TODO_COMMAND";    # the security test
my $exception_file =
  "conf/whitelists/TOD_FILE-whitelist.conf";    # the file with exceptions

# help - information about the check
my $help = <<HELP;
TODO_INFORMATION
HELP



# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
