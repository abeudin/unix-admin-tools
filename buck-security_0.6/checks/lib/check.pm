#!/usr/bin/perl

use strict;
use warnings;
use lib::exceptions;    # include exceptions sub to filter exceptions

package check;

# check.pm
# executes Bash-Oneliners
# Gets Title and command, returns Title, Result (0 or 1 where 0 is good) , and details

sub CheckBash {
    my $result         = 0;
    my $title          = shift;
    my $security_test  = shift;
    my $exception_file = shift;
    my $help = shift;
    my $opt_output     = shift;    # output errors?
    my @alarms;
    my @outcomes;
    my $outcome; # string to return
    # be verbose
    if ( $opt_output == '3' ) {
        @alarms = `$security_test`; # execute test and save outcome WITH errors
        chomp(@alarms);
    }

    # no Errors if --output=1 or 2 (for 1 see below)
    elsif ( $opt_output == '1' || $opt_output == '2' ) {
        @alarms = `$security_test 2> /dev/null`;    # execute test and save outcome WITHOUT errors
        chomp(@alarms);
    }

    # nothing found, return 0 and exit
    if ( @alarms eq "" ) {
        return ( $title, $result, 0 );    # last 0 is for $details
    }

    # Now check outcome against exceptions
    @outcomes = exceptions::CheckAgainstExceptions(\@alarms, $exception_file);
    # if nothing left, return 0 and exit
    if ( @outcomes eq 0 ) {
        return ( $title, $result, 0 );    # second 0 is for $details
        exit;
    }

    # found something which wasn't in the exceptions from config, return it
    else {
        $outcome = join( "\n", @outcomes );    # translate back to string
        $result = 1;

        # supress Details when --output=1
        if ( $opt_output == '1' ) {
            $outcome = 0;
        }

        return ( $title, $result, $help, $outcome );
    }
}

sub CheckPerl {
    my $title = shift;
    my $package_name = shift;
    my $exception_file = shift;
    my $help = shift;
    my $opt_output = shift;
    my @outcomes;
    my $result = 0;
    my $mod = $package_name . '.pm';
    # excute the check in file at /checks, @outcomes is defined there    
    require $mod;
    my $outcome; # string to return
    
    my @alarms = $package_name->perl();
    # nothing found, return 0 and exit
    if ( @alarms eq "" ) {
        return ( $title, $result, 0 );    # last 0 is for $details
    }

    # Now check outcome against exceptions
    @outcomes = exceptions::CheckAgainstExceptions(\@alarms,$exception_file);
    
    # if nothing left, return 0 and exit
    if ( @outcomes eq 0 ) {
        return ( $title, $result, 0 );    # second 0 is for $details
        exit;
    }

    # found something which wasn't in the exceptions from config, return it
    else {
        my $outcome = join( "\n", @outcomes );    # translate back to string
        $result = 1;

        # supress Details when --output=1
        if ( $opt_output == '1' ) {
            $outcome = 0;
        }

        return ( $title, $result, $help, $outcome );
    }

}


1;
