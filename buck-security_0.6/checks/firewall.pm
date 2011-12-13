#!/usr/bin/perl

use strict;
use warnings;

package firewall;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "Check firewall policies";                      
    # the filename of this file
    my $package_name        = "firewall";
    # the exception file
    my $exception_file  = "conf/whitelists/firewall-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
The following iptables policies are set to ACCEPT
which might be a security problem.
Learn more at http://buck-security/doc.html#c_firewall
HELP
    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );
}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes

my @policies = `iptables -nL | grep policy`;
my @outcomes;
foreach (@policies) {
   $_ =~ s/\(|\)//g;                # remove braces
   my @fields = split(/\s+/, $_);   # split after whitespace 
   # if policy is ACCEPT then add to outcomes
   if ($fields[3] eq 'ACCEPT') {
        push(@outcomes, "$fields[1]:$fields[3]"); # 2th and 4th field contain chainname and policy
   }
}

#
# CHECK END
######################################
return @outcomes;
}

1;
