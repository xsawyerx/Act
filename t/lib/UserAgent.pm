package t::lib::UserAgent;

use strict;
use warnings;
use Test::More;

sub new {
    my $class = shift;
    return bless {@_}, $class;
}

sub get {
    my $self = shift;
    isa_ok( $self, 't::lib::UserAgent' );
    isa_ok( $self->{'get'}, 'CODE' );
    $self->{'get'} and $self->{'get'}->(@_);
}

1;
