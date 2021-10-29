#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location

{
    my $prog = "$Bin/../script/csvdb";
    my $filename = 't/Shapes-2021-1008.csv';

    #  Load the file .. only needs to be done once.

    open( my $fh, '<', $filename );
    my $line_num = 0;
    my @data_from_file;

    while (<$fh>) {

        next if ( $line_num++ == 0 );
        s/\s+$//;

        my @row = split(/,/);
        push( @data_from_file, \@row );
    }
    close($fh);

    #  Test '*' (all fields), '1,2' (all fields, with and without an
    #  extra space) and 'sides,name' (all fields -- by name, with and without
    #  an extra space) since they are equivalent in this case.

    foreach my $select ('*', '1,2', '1, 2', 'sides,name', 'sides, name') {

        my @result =
          map { s/\s+$//; $_ } `$prog 2>&1 -o $filename -e 'select $select'`;
        ok( @result, 'Got some output from the command line call' );

        my @info_only = grep { /^INFO:/ } @result;
        like( $info_only[0], qr/$filename loaded/, 'Saw file loaded message' );

        my @data_only = grep { $_ !~ /:/ } @result;
        is( scalar @data_only, 7, 'Got the right number of lines back' );

        foreach my $n ( 0 .. $line_num - 2 ) {

            my @got = split( /\t/, $data_only[$n] );
            is_deeply( \@got, $data_from_file[$n], "Data for row $n matched" );
        }
    }

    done_testing;
}
