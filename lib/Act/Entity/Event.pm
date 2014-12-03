package Act::Entity::Event;
# ABSTRACT: An entity for an event in Act

use Moo;
use MooX::Types::MooseLike::Base qw<Int Str InstanceOf>;
with qw<
    Act::Role::Entity
    Act::Role::HasDateTime
>;

has event_id => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has [ qw<conf_id title> ] => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has [ qw<abstract url_abstract room> ] => (
    is  => 'ro',
    isa => Str,
);

has duration => (
    is  => 'ro',
    isa => Int,
);

has datetime => (
    is  => 'ro',
    isa => InstanceOf['DateTime'],
);

1;

