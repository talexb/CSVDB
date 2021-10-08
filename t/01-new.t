#!perl -T

use 5.006;
use strict;
use warnings;

use Test::More;
use Try::Tiny;
use FindBin qw/$Bin/;   #  For test file location

use CSVDB;

{
    #  Create an object without a filename, and make sure it fails.

    try {

        my $no_file = CSVDB->new();

    } catch {

        ok( 1, 'Opening without a file was caught' );
    };

    #  Create an object using our test file ..

    my $shapes = CSVDB->new ( "$Bin/Shapes-2021-1008.csv" );
    ok ( defined $shapes, 'Test file opened' );

    #  .. and just do a select on everything, so we can verify the data.

    my $data = $shapes->select;
    is ( scalar ( @{ $data } ), 7, 'Number of columns is correct' );

    foreach my $row ( @{ $data } ) {

        like ( $row->[0], qr/^\d+$/, 'First column is a number' );
        like ( $row->[1], qr/^\w+$/, 'Second column is text' );
    }

    done_testing;
}
