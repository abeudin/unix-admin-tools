#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package usermask;

my $title =
  "Check umask";    # title of the test
my $security_test = 'umask';                               # the security test
my $exception_file =
  "conf/whitelists/usermask-whitelist.conf";    # the file with exceptions

# help - information about the check
my $help = <<HELP;
Your default permissions for new files (umask) 
might represent a security risk.
Learn more at http://buck-security.org/doc.html#c_
HELP


# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
