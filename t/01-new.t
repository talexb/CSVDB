#!perl -T

use 5.006;
use strict;
use warnings;

use Test::More;
use Try::Tiny;

use CSVDB;

{
    try {

        my $no_file = CSVDB->new();

    } catch {

        ok( 1, 'Opening without a file was caught' );
    };

    done_testing;
}
