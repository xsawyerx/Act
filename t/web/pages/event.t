use utf8;
use strict;
use warnings;
use Test::More tests => 10;
use Plack::Test;
use HTTP::Request::Common;

use JSON;
use Act::Web;
use Act::Schema;
use t::corpus::Sample;
use t::lib::UserAgent;

my $event    = sample_event;
my $conf_id  = 'ya2008';
my @requests = (
    sub {
        my $url = shift;
        is(
            $url,
            "http://localhost:5050/$conf_id/event/1",
            'Got request for event 1',
        );

        return {
            success => 1,
            content => encode_json { results => [] },
        };
    },

    sub {
        my $url = shift;
        is(
            $url,
            "http://localhost:5050/$conf_id/event/3",
            'Correct URL',
        );

        return {
            success => 1,
            content => encode_json { results => [$event] },
        };
    },
);

my $user_agent = t::lib::UserAgent->new(
    get => sub { shift(@requests)->(@_) },
);

Act::Web->setup(
    api => { ua => $user_agent },
);

my $schema = Act::Web->config->{'schema'};
my $test   = Plack::Test->create( Act::Web->to_app );

subtest 'Render event' => sub {
    is(
        $test->request( GET "/$conf_id/event/1" )->code,
        404,
        'Event "1" does not exist',
    );

    my $res = $test->request( GET "/$conf_id/event/3" );
    is( $res->code, 202, 'Successfully got event "3"' );

    my $html = $res->content;
    is(
        $html,
        << "_END_HTML",
New event!
abstract: hooray
conf_id: $conf_id
datetime: 2008-05-15 18:00:00
duration: 120
event_id: 3
room: out
title: Party
url_abstract:

_END_HTML
        'Event rendered successfully',
    );
};

