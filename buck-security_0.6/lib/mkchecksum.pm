#!/usr/bin/perl

use strict;
use warnings;

package mkchecksum;

# mkchecksum.pm

# MkChecksum
sub MkChecksum {
    # Create checksums
    `$Config::checksum_program $Config::checksum_dir | gpg -c > $Config::checksum_file; chmod 600 $Config::checksum_file;`;
}

1;
