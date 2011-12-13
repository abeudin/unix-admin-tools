#!/usr/bin/perl

use strict;
use warnings;
use lib::check;    # for the "real" check Sub

package worldwriteablefiles;

my $title = "World Writeable Files";    # title of the test
my $security_test = "find / ! -fstype proc -type f -perm -2 2> /dev/null";    # the security test
my $exception_file = "conf/whitelists/worldwriteablefiles-whitelist.conf";    # the file with exceptions

# help - information about the check
my $help = <<HELP;
The following files are writeable for all users.
Learn more at http://buck-security.org/doc.html#c_wwf
HELP

# just forwarding to the "real" check Sub with variables
sub check {
    my $opt_output = $_[1];
    check::CheckBash( $title, $security_test, $exception_file, $help, $opt_output );
}

1;
