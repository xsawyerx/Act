use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;
use Try::Tiny;

use Dancer2;
use Act::Schema;
use Act::Web::API;
use t::corpus::Sample;

Act::Web::API->setup(
    Act::Schema->connect('dbi:SQLite:dbname=t/corpus/act.sqlite')
);

my $schema  = Act::Web::API->config->{'schema'};
my $test    = Plack::Test->create( Act::Web::API->to_app );
my $event   = sample_event;
my $conf_id = 'ya2008';

subtest 'Show single event' => sub {
    my $res = $test->request( GET "/$conf_id/event/$event->{'event_id'}" );
    ok( $res->is_success, 'Successful result' );

    my $data = try { decode_json $res->content };
    isa_ok( $data, 'HASH', 'Got data back' );
    is_deeply( $data, $event, 'Correct event' );
};

subtest 'List all events' => sub {
    my $res = $test->request( GET "/$conf_id/event" );
    ok( $res->is_success, 'Successful result' );

    my $data = try { decode_json $res->content };
    isa_ok( $data, 'HASH', 'Got event details' );
    is_deeply(
        $data,
        { results => [$event] },
        'Correct events',
    );
};

subtest 'List no events' => sub {
    my $res = $test->request( GET '/doesnotexist/event' );
    ok( $res->is_success, 'Successful result' );

    my $data = try { decode_json $res->content };
    isa_ok( $data, 'HASH', 'Got event details' );
    is_deeply(
        $data,
        { results => [] },
        'Correct events',
    );
};

done_testing();
