#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location
use Clone qw/clone/;

use lib "$Bin/../lib";

use CSVDB;

#  This file is just a copy of t/02-select.t, but has field names replaced with
#  column numbers.

{
    #  Create an object using our test file; this file has no header, so the
    #  tests use a one-based column number.

    my $shapes = CSVDB->new_no_header ( "$Bin/Shapes-2021-1008-no-header.csv" );
    ok ( defined $shapes, 'Test file opened' );

    #  Get data from each of the fields ..

    foreach my $field_num (1..2) {

        my $data = $shapes->select( field_num => [$field_num] );
        ok ( defined $data, 'Got a result' );

        is( scalar( @{$data} ), 7, "Field count correct for $field_num" );

        foreach my $e ( @{$data} ) {

            if ( $field_num == 1 ) {

                like( $e->[0], qr/^\d+$/, 'First column is a number' );

            } elsif ( $field_num == 2 ) {

                like( $e->[0], qr/^\w+$/, 'Second column is text' );
            }
        }
    }

    #  .. and then try getting data from a field that doesn't exist.

    my $data = $shapes->select( field_num => [ 4 ] );
    ok ( !defined $data, 'Got null result for bad field number' );
    like ( $CSVDB::errors->[0], qr/Field \d+ not found/, 'Got a good error message' );

    #  Hmm .. let's explicitly ask for all columns .. should get the same
    #  content as when we ask for everything.

    my $all_rows          = $shapes->select;
    my $explicit_all_rows = $shapes->select( field_num => [1..2] );

    is_deeply( $explicit_all_rows, $all_rows,
        'Match for implicit and explicit rows' );

    #  Test limit parameter.

    foreach my $limit ( 1..5 ) {

        my $set = $shapes->select( limit => $limit );
        is ( scalar ( @{$set} ), $limit, "Got just $limit rows" );
    }

    #  Test order by alpha. We clone the data so we can sort the copy without
    #  affecting the original data.

    my $alpha_order = $shapes->select( field_num => [ 1..2 ], order_by_alpha => 2 );
    my $alpha_copy = clone ( $alpha_order );
    $alpha_copy = [ sort { $a->[ 1 ] cmp $b->[ 1 ] } @{$alpha_copy} ];

    is_deeply ( $alpha_order, $alpha_copy, 'Data was sorted correctly' );

    done_testing;
}
