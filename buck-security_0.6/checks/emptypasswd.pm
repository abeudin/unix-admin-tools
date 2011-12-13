#!/usr/bin/perl

use strict;
use warnings;

package emptypasswd;

# just forwarding to the "real" CheckPerl Sub with variables
# title, filename of this file, exception file and error level
sub check {
    use lib::check;
    my $opt_output = $_[1];

    # the title of the check for the output
    my $title           = "Users with empty password";                      
    # the filename of this file
    my $package_name        = "emptypasswd";
    # the exception file
    my $exception_file  = "conf/whitelists/emptypasswd-whitelist.conf";
    # help - information about the check
    my $help = <<HELP;
Users which have an EMPTY password.
TODO
HELP

    check::CheckPerl( $title, $package_name, $exception_file, $help, $opt_output );
}



sub perl {

######################################
# CHECK START
# HERE IS THE PERL CODE FOR THE CHECK
# returns results as list  in @outcomes

use users;

# that will be th list of the users with empty pw
my @UsersEmptyPasswd;

# users which are shadowed (x in /etc/passwd)
my @ShadowUsers;

# user and password items from /etc/passwd
my %UsersPasswdNormal = users::PasswordsNormal();

# user and password items from /etc/shadow
my %UsersPasswdShadow = users::PasswordsShadow();

# check /etc/passwd first

while ( my ($k,$v) = each %UsersPasswdNormal ) {
    if ($v eq '') {
        push(@UsersEmptyPasswd, $k);
    }
    elsif ($v eq 'x') {
        push (@ShadowUsers, $k);
    }
} 

# now check shadowed users and their pw item in /etc/shadow

foreach (@ShadowUsers) {
    while (my ($k, $v) = each %UsersPasswdShadow) {
    
         # only check users that were shadowed in /etc/passwd
        if ($k eq $_) {
            push(@UsersEmptyPasswd, $k) if $v eq '';
        }
    }
}   

my @outcomes = @UsersEmptyPasswd;
#
# CHECK END
######################################
return @outcomes;
}

1;
