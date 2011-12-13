#!/usr/bin/perl

use strict;
use warnings;

package services;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "Listening Services";                      
    # the filename of this file
    my $package_name        = "services";
    # the exception file
    my $exception_file  = "conf/whitelists/services-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
The following programs are listening for incoming
connections. Output format is port:program:listen_mode
Learn more at http://buck-security/doc.html#c_services
HELP
 
    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );

}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes

my @netstat = `netstat -luntp`;
#my @netstat = `netstat -luntp | awk '{print \$4, \$7}'`;
# delete first two netstat output rows, contain genereal information only
splice(@netstat,0,2);

my @outcomes;
# hash where service results are "cleared", 
# so every service:port combination only exists once 
my %clear; 
foreach (@netstat) {
    
    # local address is before : with Port an Whitespace
    my ($local_address) = $_ =~ /(\S*):\d+\s/;
    if ($local_address eq '127.0.0.1' || $local_address eq '::1') {
        $local_address = 'LISTEN_LOCAL';
    }
    elsif ($local_address eq '0.0.0.0' || $local_address eq '::') {
        $local_address = 'LISTEN_ALL';
    }
    # port is the number after the first colon (:)
    my ($port) = $_ =~ /:(\d+)\s/;
    # program is the string after the slash (/)
    my ($program) = $_ =~ /\/([\w|-]+)/;
    if (!$program) {$program = "UNKNOWN"}
 
    $clear{$port} = "$program:$local_address"; 
}

for(sort {$a <=> $b} keys %clear) {
     push(@outcomes, "$_:$clear{$_}");
     }



#
# CHECK END
######################################
return @outcomes;
}

1;
