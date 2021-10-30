# NAME

CSVDB - Access a CSV file like a database

# VERSION

Version 0.01

# SYNOPSIS

Specify a CSV file, then access it like a database table.

Perhaps a little code snippet.

    use CSVDB;

    #  The shapes.csv file has data like
    #       3,triangle
    #       4,square
    #       .. and so on.

    my $shapes = CSVDB->new( 'shapes.csv' );
    my $sides = $shapes->select( fields => 'sides' );

    #  The sides arrayref now has a list of the shapes' sides.

    my $smaller_sides =
      $shapes->select( fields => 'sides', where => 'sides <= 12' );

    #  The smaller_sides arrayref ow has a list of shapes' sides that are less
    #  than or equal to 12.

    ...

# EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

# SUBROUTINES/METHODS

## new

Create a new CSVDB object. Expects a filename and a boolean reflecting whether
there's a header present that describes each column.

## select

Performs a select operation on the CSVDB object. Possible arguments are

- fields: A list of either field names or of field numbers (one-based)
- where: A simple condition that limits or filters rows (not yet implemented).
- limit: An upper limit on the number of rows return.

An arrayref of results is returned; if there are errors, they can be found in
the arrayref $CSVDB::errors.

# AUTHOR

T. Alex Beamish, `<talexb at gmail.com>`

# BUGS

Please report any bugs or feature requests to `bug-csvdb at rt.cpan.org`, or through
the web interface at [https://rt.cpan.org/NoAuth/ReportBug.html?Queue=CSVDB](https://rt.cpan.org/NoAuth/ReportBug.html?Queue=CSVDB).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CSVDB

You can also look for information at:

- RT: CPAN's request tracker (report bugs here)

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=CSVDB](https://rt.cpan.org/NoAuth/Bugs.html?Dist=CSVDB)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/CSVDB](http://annocpan.org/dist/CSVDB)

- CPAN Ratings

    [https://cpanratings.perl.org/d/CSVDB](https://cpanratings.perl.org/d/CSVDB)

- Search CPAN

    [https://metacpan.org/release/CSVDB](https://metacpan.org/release/CSVDB)

# ACKNOWLEDGEMENTS

# LICENSE AND COPYRIGHT

This software is Copyright (c) 2021 by T. Alex Beamish.

This is free software, licensed under:

    The Artistic License 2.0 (GPL Compatible)
