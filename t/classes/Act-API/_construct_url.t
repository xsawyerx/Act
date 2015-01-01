use strict;
use warnings;
use Test::More tests => 2;
use Act::API;

subtest 'Defaults' => sub {
    my $api = Act::API->new();
    can_ok( $api, '_construct_url' );
};

subtest '_construct_url' => sub {
    my $api = Act::API->new();
    my $url
        = $api->_construct_url( 'Event' => { id => 30, conf_id => 'myconf' },
        );
    is( $url, '/myconf/event/30', 'Construct correct URL' );
};
