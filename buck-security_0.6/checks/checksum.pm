#!/usr/bin/perl

use strict;
use warnings;

package checksum;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "Checksums of system programs";                      
    # the filename of this file
    my $package_name        = "checksum";
    # the exception file
    my $exception_file  = "conf/whitelists/checksum-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
The checksums for the following files have changed,
since you created them. This could indicate an attack.
Learn more at http://buck-security.org/doc.html#c_checksums 
HELP


    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );
}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes
my $checksums_file = $Config::checksum_file;
my $checksums_prog = $Config::checksum_program;
my @outcomes;
# only if checksum file exists
if (-e $checksums_file) {
    print "\n------------------\nSTARTING CHECKSUM CHECK\nDecrypting checksum-file $checksums_file ...\n";
    @outcomes = `gpg -d $checksums_file 2> /dev/null | $checksums_prog -cw | grep -v ": OK";`;
}
else {
    push(@outcomes, "Couldn't read $checksums_file: $!\n");
}
#
# CHECK END
######################################
return @outcomes;
}

1;
