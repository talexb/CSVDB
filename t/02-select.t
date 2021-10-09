#!perl -T

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location

use CSVDB;

{
    #  Create an object using our test file;

    my $shapes = CSVDB->new ( "$Bin/Shapes-2021-1008.csv" );
    ok ( defined $shapes, 'Test file opened' );

    #  Get data from each of the fields ..

# TODO:
#   {
#       local $TODO = 'Under development';

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
#   }

    #  .. and then try getting data from a field that doesn't exist.

    my $data = $shapes->select( fields => [ qw/bogus/ ] );
    ok ( !defined $data, 'Got null result for bad field name' );
    like ( $CSVDB::errors->[0], qr/Field \w+ not found/, 'Got a good error message' );

    done_testing;
}
