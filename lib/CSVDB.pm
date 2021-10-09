package CSVDB;

use 5.006;
use strict;
use warnings;

use Carp;
use autodie;
use Text::CSV;

=head1 NAME

CSVDB - Access a CSV file like a database

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

our $errors;    #  This is an array_ref.

=head1 SYNOPSIS

Specify a CSV file, then access it like a database table.

Perhaps a little code snippet.

    use CSVDB;

    my $shapes = CSVDB->new( 'shapes.csv' );
    my $sides = $shapes->select( fields => 'sides' );

    #  The sides arrayref now has a list of the shapes' sides.

    my $smaller_sides =
      $shapes->select( fields => 'sides', where => 'sides <= 12' );

    #  The smaller_sides arrayref ow has a list of shapes' sides that are less
    #  than or equal to 12.

    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub new
{
    my ( $class, $filename ) = @_;
    defined $filename or croak "Must specify filename";

    $errors = [];

    #  Text::CSV is doing all of the heavy lifting here.

    my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
    open ( my $fh, '<', $filename );

    my $self = { filename => $filename };

    my $first_line = 1;
    while ( my $row = $csv->getline ($fh)) {

        #  We're assuming that the first line will be the column headers (i.e.,
        #  field names), and all subsequent lines will be data.

        if ( $first_line ) {

            $self->{cnames} = $row;
            $first_line = 0;

        } else {

            push ( @{ $self->{ data } }, $row );
        }
    }
    close ( $fh );

    bless $self, $class;
    return $self;
}

sub select
{
    my ( $self, %args )  = @_;

    $errors = [];

    #  When there are no fields or clauses, we just return everything.

    if ( !exists ( $args{ fields } ) && !exists $args{ where } ) {

        return ( $self->{ data } );
    }

    #  There are fields? Get the offsets for each field, and return the data
    #  for those offsets.

    my @field_offsets;
    my @errors;

    my $off = 0;
    my %field_names = map { $_ => $off++ } @{$self->{ cnames }};

    foreach my $name ( @{ $args{ fields } } ) {

        if ( exists $field_names{$name} ) {

            push( @field_offsets, $field_names{$name} );

        } else {

            push( @errors, "Field $name not found in table" );
        }
    }

    #  If we were asked for fields that were not found, report that error and
    #  return nothing.

    if ( @errors ) {

        $errors = \@errors;
        return undef;
    }

    my @data;

    foreach my $row ( @{ $self->{ data } } ) {

        push ( @data, [ map { $row->[ $_ ] } @field_offsets ] );
    }

    return ( \@data );
}

=head1 AUTHOR

T. Alex Beamish, C<< <talexb at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-csvdb at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=CSVDB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc CSVDB


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=CSVDB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/CSVDB>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/CSVDB>

=item * Search CPAN

L<https://metacpan.org/release/CSVDB>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2021 by T. Alex Beamish.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of CSVDB
