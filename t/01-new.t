#!perl -T

use 5.006;
use strict;
use warnings;

use Test::More;
use Try::Tiny;
use FindBin qw/$Bin/;   #  For test file location

use CSVDB;

{
    try {

        my $no_file = CSVDB->new();

    } catch {

        ok( 1, 'Opening without a file was caught' );
    };

    my $shapes = CSVDB->new ( "$Bin/Shapes-2021-1008.csv" );
    ok ( defined $shapes, 'Test file opened' );

    done_testing;
}
