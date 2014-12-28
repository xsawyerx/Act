use strict;
use warnings;
use Test::More tests => 4;
use Test::Fatal;
use t::corpus::Sample;

use_ok('Act::ResultSet');

subtest 'Defaults' => sub {
    ok(
        exception { Act::ResultSet->new },
        'Cannot create resultset without type',
    );

    my $rs;
    is(
        exception { $rs = Act::ResultSet->new( type => 'Event' ) },
        undef, 'Create resultset with type',
    );

    isa_ok( $rs, 'Act::ResultSet' );
    can_ok( $rs, qw<type items total all next> );
};

subtest 'ResultSet all()' => sub {
    my $rs = Act::ResultSet->new(
        type  => 'Event',
        items => [sample_event],
    );

    is( $rs->total, 1, 'total() says only one event' );
    my @events = $rs->all();
    is( scalar @events, 1, 'all() returned one event' );
};

subtest 'ResultSet next() iterator' => sub {
    my $rs = Act::ResultSet->new(
        type  => 'Event',
        items => [sample_event],
    );

    my $count = 0;
    while ( my $event = $rs->next ) {
        $count++;
        isa_ok( $event, 'Act::Entity::Event' );
        can_ok(
            $event,
            qw<event_id conf_id title abstract url_abstract room duration datetime>,
        );

        ok( $event->$_, "Required $_ has value" )
            for qw<event_id conf_id title>;
    }

    is( $count, 1, 'Only one event through iterator' );
};
