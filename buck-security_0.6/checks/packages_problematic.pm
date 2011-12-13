#!/usr/bin/perl

use strict;
use warnings;

package packages_problematic;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "Search problematic packages";                      
    # the filename of this file
    my $package_name        = "packages_problematic";
    # the exception file
    my $exception_file  =    "conf/whitelists/packages_problematic-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
The following packages are installed and may be a
security risk.
Learn more at http://buck-security.org/doc.html#c_pkg
HELP

    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );
}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes

use lib::packages;

# list of security tools which can be used by attackers too
my @packages = @Config::problematic_packages;
# Check if installed, returns Hash with: Name => 0 or 1 (1 if installed)
my %Status = packages::IsInstalled(\@packages);

my @outcomes = grep { $Status{$_} == 1 } keys %Status;

#
# CHECK END
######################################
return @outcomes;
}

1;
