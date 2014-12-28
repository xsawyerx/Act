package Act::API;

use Moo;
use MooX::Types::MooseLike::Base qw<Int Str Object>;
use Carp;
use JSON;
use Try::Tiny;
use HTTP::Tiny;
use List::Util 'first';
use Act::ResultSet;
use Act::Entity::Event;

with 'Act::Role::Abstract';

has ua => (
    is      => 'ro',
    isa     => Object,
    lazy    => 1,
    builder => '_build_ua',
);

has host => (
    is      => 'ro',
    isa     => Str,
    default => sub {'localhost'},
);

has port => (
    is      => 'ro',
    isa     => Int,
    default => sub {5050},
);

has base_url => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return sprintf 'http://%s:%s', $self->host, $self->port;
    },
);

my @supported_types = qw<
    Event News Talk Track User
>;

sub _build_ua { HTTP::Tiny->new }

sub _request {
    my ( $self, $args ) = @_;

    my ( $method, $url );
    if ( ref $args eq 'ARRAY' ) {
        $method = lc $args->[0];
        $url    = $args->[1];
    } else {
        $method = 'get';
        $url    = $args;
    }

    my $response = $self->ua->$method($url);

    $response->{'success'}
        or croak "Request to $url failed: " . $response->{'reason'};

    my $data = try { decode_json $response->{'content'} }
    catch { croak "Decoding content failed: $_" };

    return $data;
}

sub _search {
    my ( $self, $entity, $opts ) = @_;

    $entity or croak 'Entity required';

    first { $entity eq $_ } @supported_types
        or croak "Entity $entity is not supported";

    my $entity_class = "Act::Entity::$entity";
    my $url
        = $entity_class->can('construct_url')
        ? $entity_class->_construct_url($opts)
        : $self->_construct_url( $entity, $opts );

    my $base = $self->base_url;
    my $data = $self->_request( $base . $url );

    return Act::ResultSet->new(
        type  => $entity,
        items => $data->{'results'},
    );
}

sub _construct_url {
    my ( $self, $entity, $opts ) = @_;

    my $conf_id = $opts->{'conf_id'}
        or croak 'conf_id required';

    my $url = join '/', '', lc $conf_id, lc $entity;
    return $opts->{'id'} ? "$url/" . $opts->{'id'} : $url;
}

sub event {
    my ( $self, @args ) = @_;

    # complex search - ResultSet always
    @args == 1
        and ref $args[0] eq 'HASH'
        and return $self->_search( Event => $args[0] );

    # asked for specific one
    my ( $conf_id, $id ) = @args;
    my $rs = $self->_search( Event => { id => $id, conf_id => $conf_id } );

    $rs->total > 1
        and croak 'Asked for a single event but got multiple';

    return $rs->next;
}

1;
