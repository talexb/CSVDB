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

#  Object constructor.

sub new
{
    my ( $class, $filename ) = @_;
    defined $filename or croak "Must specify filename";

    $errors = [];

    open ( my $fh, '<', $filename );
    my $self = { filename => $filename };

    _load ( $self, $fh, 1 );

    close ( $fh );

    bless $self, $class;
    return $self;
}

sub new_no_header
{
    my ( $class, $filename ) = @_;
    defined $filename or croak "Must specify filename";

    $errors = [];

    open ( my $fh, '<', $filename );
    my $self = { filename => $filename };

    _load ( $self, $fh, 0 );

    close ( $fh );

    bless $self, $class;
    return $self;
}

#  This loads the contents of the CSV into the object.

sub _load
{
    my ( $self, $fh, $header_present ) = @_;

    #  Text::CSV is doing all of the heavy lifting here.

    my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
    while ( my $row = $csv->getline ($fh)) {

        #  We're assuming that the first line will be the column headers (i.e.,
        #  field names), and all subsequent lines will be data.

        if ( $header_present ) {

            $self->{cnames} = $row;
            $header_present = 0;

        } else {

            push ( @{ $self->{ data } }, $row );
        }
    }
}

sub select
{
    my ( $self, %args )  = @_;

    $errors = [];

    #  When there are no fields, field numbers, clauses or limits, we just
    #  return everything.

    if (   !exists( $args{fields} )
        && !exists( $args{field_num} )
        && !exists $args{where}
        && !exists $args{limit} )
    {

        return ( $self->{data} );
    }

    my @field_offsets;
    my @errors;

    #  There are field names? Get the offsets for each field name (aka column
    #  names or just cnames), and return the data for those column offsets.

    if ( exists ( $args{fields} ) ) {

        my $off = 0;    #  Maps the column names to column number.
        my %cnames = map { $_ => $off++ } @{$self->{ cnames }};

        foreach my $name ( @{ $args{ fields } } ) {

            if ( exists $cnames{$name} ) {

                push( @field_offsets, $cnames{$name} );

            } else {

                push( @errors, "Field $name not found in table" );
            }
        }
    }

    elsif ( exists ( $args{ field_num } ) ) {

        foreach my $field_num ( @{ $args{ field_num } } ) {

            if ( $field_num > scalar ( @{ $self->{ data }->[0] } ) ) {

                push ( @errors, "Field $field_num not found in table" );

            } else {

                push ( @field_offsets, $field_num-1 );
            }
        }
    }

    #  If any of the fields we were asked for were not found, report that error and
    #  return nothing.

    if ( @errors ) {

        $errors = \@errors;
        return undef;
    }

    #  Collect the data and return it. If there's a limit, do that.

    my @data;
    my $limit = 0;

    if ( exists $args{limit} ) { $limit = $args{limit}; }

    foreach my $row ( @{ $self->{data} } ) {

        push( @data, [ map { $row->[$_] } @field_offsets ] );
        if ( $limit ) {

            last if ( --$limit == 0 );
        }
    }

    #  Is the data supposed to be sorted? (Just handle sorted a single field
    #  for now.) (Also, order by needs to know if we're doing alpha sorting
    #  using cmp or numeric sorting using <=> -- hence order_by_alpha.)

    if ( exists( $args{fields} ) ) {

        my $off    = 0;    #  Maps the output field names to offset.
        my %onames = map { $_ => $off++ } @{ $args{fields} };

        if ( exists $args{order_by_alpha} ) {

            #  TODO: Check that this is a valid field name.
            my $offset = $onames{ $args{order_by_alpha} };
            @data = sort { $a->[$offset] cmp $b->[$offset] } @data;
        }
    }

    elsif ( exists ( $args{ field_num } ) ) {

        if ( exists $args{order_by_alpha} ) {

            #  TODO: Check that this is a valid field number.
            my $offset = $args{order_by_alpha} - 1;
            @data = sort { $a->[$offset] cmp $b->[$offset] } @data;
        }
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
