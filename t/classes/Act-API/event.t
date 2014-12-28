use strict;
use warnings;
use Test::More tests => 6;
use Test::Fatal;
use Act::API;
use JSON;
use t::corpus::Sample;
use t::lib::UserAgent;

subtest 'Defaults' => sub {
    my $api = Act::API->new();
    can_ok( $api, 'event' );
    like(
        exception { $api->event() },
        qr/^conf_id required/,
        'event() must provide a conf_id or hashref',
    );
};

my $single_result = {
    success => 1,
    content => encode_json { results => [sample_event] },
};

my $multiple_result = {
    success => 1,
    content => encode_json { results => [ sample_event, sample_event ] },
};

subtest 'event() with multi result when asked for one' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1,
        ua   => t::lib::UserAgent->new(
            get => sub {
                is(
                    $_[0],
                    'http://localhost:1/conf/event/30',
                    'Correct request created',
                );

                return $multiple_result;
            },
        )
    );

    like(
        exception { $api->event( 'conf', 30 ) },
        qr{^Asked for a single event but got multiple},
        'Multiple results with an ID crashed',
    );
};

subtest 'event() with one result when asked for one' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1,
        ua   => t::lib::UserAgent->new(
            get => sub {
                is(
                    $_[0],
                    'http://localhost:1/conf/event/30',
                    'Correct request created',
                );

                return $single_result;
            },
        )
    );

    my @events = $api->event( 'conf', 30 );
    is( scalar @events, 1, 'Only one result' );
    isa_ok( $events[0], 'Act::Entity::Event' );
};

subtest 'event() with multi result' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1,
        ua   => t::lib::UserAgent->new(
            get => sub {
                is(
                    $_[0],
                    'http://localhost:1/conf/event',
                    'Correct request created',
                );

                return $multiple_result;
            },
        )
    );

    my @rs = $api->event( { conf_id => 'conf' } );
    is( scalar @rs, 1, 'Only got one resultset' );
    isa_ok( $rs[0], 'Act::ResultSet' );
};

subtest 'event() with no result when asked for one' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1,
        ua   => t::lib::UserAgent->new(
            get => sub {
                is(
                    $_[0],
                    'http://localhost:1/conf/event/30',
                    'Correct request created',
                );

                return {
                    success => 1,
                    content => '{"results":[]}',
                };
            },
        )
    );

    my @events = $api->event( conf => 30 );
    is( scalar @events, 0, 'No events received' );
};

subtest 'event() with no result when asked for one' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1,
        ua   => t::lib::UserAgent->new(
            get => sub {
                is(
                    $_[0],
                    'http://localhost:1/conf/event',
                    'Correct request created',
                );

                return {
                    success => 1,
                    content => '{"results":[]}',
                };
            },
        )
    );

    my @rs = $api->event( { conf_id => 'conf' } );
    is( scalar @rs, 1, 'Only one resultset' );
    isa_ok( $rs[0], 'Act::ResultSet', 'It is a resultset' );
    is( $rs[0]->total, 0, 'No results in it' );
};
