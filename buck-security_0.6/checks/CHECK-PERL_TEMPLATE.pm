#!/usr/bin/perl

use strict;
use warnings;

package !PACKAGENAME;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "TODO_TITLE";                      
    # the filename of this file
    my $package_name        = "TODO_PACKAGENAME";
    # the exception file
    my $exception_file  = "conf/whitelists/TODO_FILE-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
TODO_INFORMATION
HELP

    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );
}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes

TODO_COMMAND

#
# CHECK END
######################################
return @outcomes;
}

1;
