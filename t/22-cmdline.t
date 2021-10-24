#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use FindBin qw/$Bin/;   #  For test file location

{
    my $prog = "$Bin/../bin/csvdb";
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

    #  Test the limit clause by asking for 1 .. 7 rows, and confirming we get
    #  a) the right number and b) the right values.

    foreach my $limit ( 1 .. 7 ) {

        #  Run the command, and do all of the usual checks ..

        my @result = map { s/\s+$//; $_ }
          `$prog 2>&1 -o $filename -e 'select * limit $limit'`;
        ok( @result, "Got some output from the command line call" );

        my @info_only = grep { /^INFO:/ } @result;
        like( $info_only[0], qr/$filename loaded/, 'Saw file loaded message' );

        my @data_only = grep { $_ !~ /:/ } @result;
        is( scalar @data_only, $limit, 'Got the right number of lines back' );

        #  Within that, test each of the columns to make sure they match.

        foreach my $col ( 1 .. 2 ) {

            foreach my $n ( 0 .. $limit - 1 ) {

                my @got = split( /\t/, $data_only[$n] );
                is(
                    $got[$col - 1 ],
                    $data_from_file[$n]->[ $col - 1 ],
                    "Data for row $n matched"
                );
            }
        }
    }

    done_testing;
}
