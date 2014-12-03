use strict;
use warnings;
use Test::More tests => 3;
use Test::Fatal;
use JSON;
use Act::API;
use t::lib::UserAgent;
use t::corpus::Sample;

subtest 'Defaults' => sub {
    my $api = Act::API->new();
    can_ok( $api, '_search' );
};

subtest '_search() with unsupported type' => sub {
    my $api = Act::API->new();

    like(
        exception { $api->_search({ type=> 'NotSupported' }) },
        qr{^Search type NotSupported is not supported},
        'Cannot search for an unsupported type',
    );
};

subtest '_search()' => sub {
    my $api = Act::API->new(
        host => 'localhost',
        port => 1000,
        ua   => t::lib::UserAgent->new(
            get => sub {
                my $url = shift;
                is(
                    $url,
                    'http://localhost:1000/myconf/event/10',
                    'Correct request to UA',
                );

                return {
                    success => 1,
                    content => encode_json {
                        results => [ sample_event ],
                    },
                };
            },
        ),
    );

    my $rs = $api->_search({
        id       => 10,
        type     => 'event',
        conf_id  => 'myconf',
    });

    isa_ok( $rs, 'Act::ResultSet' );
};
