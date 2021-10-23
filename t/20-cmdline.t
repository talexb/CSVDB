#!perl

use 5.006;
use strict;
use warnings;

use Test::More;
use Try::Tiny;
use FindBin qw/$Bin/;   #  For test file location

{
    my $prog = "$Bin/../bin/csvdb";
    my $filename = 't/Shapes-2021-1008.csv';

    my @result = map { s/\s+$//; $_ } `$prog -o $filename -e 'select *'`;
    ok ( @result, 'Got some output from the command line call' );

    my @info_only = grep { /^INFO:/ } @result;
    like ( $info_only[0], qr/$filename loaded/, 'Saw file loaded message' );

    my @data_only = grep { $_ !~ /:/ } @result;
    is ( scalar @data_only, 7, 'Got the right number of lines back' );

    open ( my $fh, '<', $filename );
    my $line_num = 0;
    my @data;

    while (<$fh>) {

        next if ( $line_num++ == 0 );
        s/\s+$//;

        my @row = split(/,/);
        push ( @data, \@row );
    }
    close ( $fh );

    foreach my $n ( 0 .. $line_num - 2 ) {

        my @got = split( /\t/, $data_only[$n] );
        is_deeply( \@got, $data[$n], "Data for row $n matched" );
    }

    done_testing;
}
