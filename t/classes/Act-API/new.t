use strict;
use warnings;
use Test::More tests => 1;
use Act::API;

subtest 'Defaults' => sub {
    my $api = Act::API->new( host => 'localhost', port => 3000 );
    isa_ok( $api, 'Act::API' );
    can_ok( $api, qw<ua host port base_url> );

    isa_ok( $api->ua, 'HTTP::Tiny' );
    is( $api->host, 'localhost', 'host attribute' );
    is( $api->port, 3000, 'port attribute' );
    is(
        $api->base_url,
        'http://localhost:3000',
        'base_url attribute',
    );
};
