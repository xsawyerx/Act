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
};

my $single_result = {
    success => 1,
    content => encode_json { results => [ sample_event ] },
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
        exception { $api->event({ id => '30', conf_id => 'conf' }) },
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

    my ($event) = $api->event({ id => 30, conf_id => 'conf' });
    isa_ok( $event, 'Act::Entity::Event' );
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

    my ($rs) = $api->event({ conf_id => 'conf' });
    isa_ok( $rs, 'Act::ResultSet' );
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

    my ($event) = $api->event({ id => 30, conf_id => 'conf' });
    is( $event, undef, 'No event received' );

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

    my ($rs) = $api->event({ conf_id => 'conf' });
    isa_ok( $rs, 'Act::ResultSet', 'No event received' );
};
