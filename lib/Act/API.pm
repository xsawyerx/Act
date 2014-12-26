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

    my $data = try   { decode_json $response->{'content'}  }
               catch { croak "Decoding content failed: $_" };

    return $data;
}

sub _search {
    my ( $self, $conf_id, $type, $args ) = @_;

    my $type   = $args->{'type'};
    my @params = map +(
        defined $_ ? $_ : ()
    ), $args->{'conf_id'}, $type, $args->{'id'};

    first { $type eq lc $_ } @supported_types
        or croak "Search type $type is not supported";

    my $url  = join '/', @params;
    my $base = $self->base_url;
    my $data = $self->_request("$base/$url");

    return Act::ResultSet->new(
        type  => $type,
        items => $data->{'results'},
    );
}

sub event {
    my ( $self, $args ) = @_;

    # complex search - ResultSet always
    ref $args eq 'HASH'
        and return $self->_search( event => $args );

    # asked for specific one
    my $rs = $self->_search( event => { id => $args } );

    $rs->total > 1
        and croak 'Asked for a single event but got multiple';

    return $rs->next;
}

1;
