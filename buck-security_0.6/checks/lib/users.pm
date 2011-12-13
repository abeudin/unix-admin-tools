#!/usr/bin/perl

use strict;
use warnings;


package users;

# users.pm
# includes subs for checking user specific stuff

sub ReadEtcPasswd {

    my $passwd_file = '/etc/passwd';
    open(PASSWD, '<', $passwd_file)
        or die "Couldn't open $passwd_file for reading: $!\n";
    my @file = <PASSWD>;
    close(PASSWD);
    return @file;
}

sub ReadEtcShadow {

    my $passwd_file = '/etc/shadow';
    open(PASSWD, '<', $passwd_file)
        or die "Couldn't open $passwd_file for reading: $!\n";
    my @file = <PASSWD>;
    close(PASSWD);
    return @file;
}




sub UsersWithValidShell {
    # list of users with valid shell as array
    my @users_valid_shell;
    my @passwd_file = ReadEtcPasswd();
    # root:x:0:0:root:/root:/bin/bash
    foreach my $line (@passwd_file) {
       $line =~
       /(.*):(.*):(.*):(.*):(.*):(.*):(.*)/; 
       # if $7 (the shell) isnt set to the following add to valid shells
       $7 ne '/bin/false' && $7 ne '/usr/sbin/nologin' && $7 ne '/bin/sync'
       ? 
       push(@users_valid_shell, $1)
       :
       next;
    }
    return @users_valid_shell;

}


# get password items from /etc/passwd
sub PasswordsNormal {
    my %UserPasswordNormal; 
    my @passwd_file = ReadEtcPasswd();
    foreach my $line (@passwd_file) {
       $line =~
       /(.*):(.*):(.*):(.*):(.*):(.*):(.*)/;
       $UserPasswordNormal{$1} = $2;
    }

    return %UserPasswordNormal;
}

# get password items from /etc/shadow
sub PasswordsShadow {
    my %UserPasswordShadow;
    my @passwd_file = ReadEtcShadow();
    foreach my $line (@passwd_file) {
       $line =~
       /(.*):(.*):(.*):(.*):(.*):(.*):(.*):(.*):(.*)/;
       $UserPasswordShadow{$1} = $2;
    }

    return %UserPasswordShadow;
}


sub Test {


my @test = UsersWithValidShell();
my %normal = PasswordsNormal();
my %shadow = PasswordsShadow();

while ( my ($k,$v) = each %normal ) {
    print "$k => $v\n";
}

while ( my ($k,$v) = each %shadow ) {
    print "$k => $v\n";
}


foreach (@test) {
#    print "$_\n";
}



}




1;
