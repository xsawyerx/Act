package Act::ResultSet;

# ABSTRACT: Act object for representing entity resultsets

use Moo;
use MooX::Types::MooseLike::Base qw<Bool Int Str ArrayRef>;
use Class::Load 'load_class';

has type => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has items => (
    is        => 'ro',
    isa       => ArrayRef,
    predicate => 'has_items',
);

has total => (
    is      => 'ro',
    isa     => Int,
    default => sub {
        my $self = shift;
        $self->has_items ? scalar @{ $self->items } : 0;
    },
);

sub all {
    my $self  = shift;
    my @items = ();

    while ( my $item = $self->next ) {
        push @items, $item;
    }

    return @items;
}

sub next {
    my $self = shift;
    my $item = shift @{ $self->items };

    defined $item or return;

    my $class = 'Act::Entity::' . $self->type;
    load_class($class);

    return $class->new($item);
}

1;
