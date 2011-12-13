#!/usr/bin/perl

use strict;
use warnings;

package exceptions;

# exceptions.pm


# GetExceptions
# Takes file with exceptions, reads it, get exceptions and return them as array
# See Perl Cookbook 8.16

sub GetExceptions {
    my $config_file = shift;
    open( CONFIG, "<", $config_file )
      or die "Couldn't read $config_file: $!\n";

    my @exceptions = <CONFIG>;
    @exceptions = grep { $_ !~ /^#/ && $_ !~ /^\s+$/ }
      @exceptions;    # no comments (starting with #) or empty lines

# removing any comments at the end of lines (for example: alice  #admin rights for alice allowed)
    foreach (@exceptions) {
        chomp;
        s/#.*//;
    }
    return @exceptions;
}

# CheckAgainstExceptions
# Checks alarms against exceptions
# if outcome is left after checking against exceptions, returns outcome in @outcomes
# if nothing left returns @outcomes = 0
# needs $outcome as argument

sub CheckAgainstExceptions {
    my $alarms_ref = shift;
    my @alarms = @{$alarms_ref};
    my $exception_file = shift;
    my @outcomes;
    # EXCEPTION PROCESSING
    # get exceptions and alarms and compare: @outcomes = alarms which are no exceptions
    # Code found at http://www.perlmonks.org/?node_id=2461

    # only if exception file exists
    if (-e $exception_file) {
        my @all_exceptions = GetExceptions($exception_file);
        # get exceptions with wildcard
        my @wildcard_exceptions = grep( /\*/, @all_exceptions );
        # TODO: have to run grep two times to split, not very elegant
        my @normal_exceptions = grep( !/\*/, @all_exceptions );

        # remove normal exceptions first
        my %normal_exceptions = map { $_ => 1 } @normal_exceptions;
        my %alarms            = map { $_ => 1 } @alarms;
        @outcomes = grep( !defined $normal_exceptions{$_}, @alarms );

        # Now lets see if there are wildcard exceptions (including a *)
        if (@wildcard_exceptions) {
            my %outcomes = map { $_ => 1 }
                @outcomes;    # make hash out of outcomes, set all element to 1

            # run through outcomes
            foreach my $hit (@outcomes) {

                # run through wildcard execption
                foreach my $wildcard (@wildcard_exceptions) {
                    if ( $hit =~ /^$wildcard/ ) {

                    # if wildcard matches outcome set it to 0 in hash (default is 1)
                        $outcomes{$hit} = 0;
                    }
                }

        }

        # put all the elements still set to 1 (which means no wildcard exception had matched) in @outcomes
        @outcomes = grep { $outcomes{$_} == 1 } keys %outcomes;
        @outcomes = sort(@outcomes);    # sort it
        }
    }
    # if no exception file all alarms are passed trough
    else {
        @outcomes = @alarms;
    }

    return @outcomes;

}


1;
