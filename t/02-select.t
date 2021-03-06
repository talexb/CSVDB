#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location
use Clone qw/clone/;

use lib "$Bin/../lib";

use CSVDB;

{
    #  Create an object using our test file;

    my $shapes = CSVDB->new ( "$Bin/Shapes-2021-1008.csv", 1 );
    ok ( defined $shapes, 'Test file opened' );

    #  Get data from each of the fields ..

    foreach my $field (qw/sides name/) {

        my $data = $shapes->select( fields => [$field] );
        ok ( defined $data, 'Got a result' );

        is( scalar( @{$data} ), 7, "Field count correct for $field" );

        foreach my $e ( @{$data} ) {

            if ( $field eq 'sides' ) {

                like( $e->[0], qr/^\d+$/, 'First column is a number' );

            } elsif ( $field eq 'name' ) {

                like( $e->[0], qr/^\w+$/, 'Second column is text' );
            }
        }
    }

    #  .. and then try getting data from a field that doesn't exist.

    my $data = $shapes->select( fields => [ qw/bogus/ ] );
    ok ( !defined $data, 'Got null result for bad field name' );
    like ( $CSVDB::errors->[0], qr/Field \w+ not found/, 'Got a good error message' );

    #  Hmm .. let's explicitly ask for all columns .. should get the same
    #  content as when we ask for everything.

    my $all_rows          = $shapes->select;
    my $explicit_all_rows = $shapes->select( fields => [qw/sides name/] );

    is_deeply( $explicit_all_rows, $all_rows,
        'Match for implicit and explicit rows' );

    #  Test limit parameter.

    foreach my $limit ( 1..5 ) {

        my $set = $shapes->select( limit => $limit );
        is ( scalar ( @{$set} ), $limit, "Got just $limit rows" );
    }

    #  Test order by alpha. We clone the data so we can sort the copy without
    #  affecting the original data.

    my $alpha_order = $shapes->select( fields => [ qw/name/ ], order_by_alpha => 'name' );
    my $alpha_copy = clone ( $alpha_order );
    $alpha_copy = [ map { [ $_ ] } sort { $a cmp $b } map { $_->[0] } @{$alpha_copy} ];

    is_deeply ( $alpha_order, $alpha_copy, 'Data was sorted correctly' );

    done_testing;
}
