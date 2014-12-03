package Act::Entity::Talk;
# ABSTRACT: An Act Talk entity

use Moo;
use MooX::Types::MooseLike::Base qw<Bool Int Str InstanceOf>;
with qw<
    Act::Role::Entity
    Act::Role::HasDateTime
>;

has [ qw<id user_id> ] => (
    is       => 'ro',
    isa      => Int,
    required => 1,
);

has [ qw<conf_id title> ] => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

has [ qw<abstract url_abstract url_talk comment room lang> ] => (
    is  => 'ro',
    isa => Str,
);

has [ qw<duration track_id>] => (
    is  => 'ro',
    isa => Int,
);

has [ qw<lightning accepted confirmed> ] => (
    is       => 'ro',
    isa      => Bool,
    default  => sub {0},
    required => 1,
);

has datetime => (
    is  => 'ro',
    isa => InstanceOf['DateTime'],
);

has level => (
    is      => 'ro',
    isa     => Int,
    default => sub {1},
);

1;
