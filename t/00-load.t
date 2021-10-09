#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location

use lib "$Bin/../lib";

BEGIN {
    use_ok( 'CSVDB' ) || print "Bail out!\n";
}

{
    diag( "Testing CSVDB $CSVDB::VERSION, Perl $], $^X" );
    done_testing;
}
