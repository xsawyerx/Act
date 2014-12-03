package Act::Web::API::Event;
# ABSTRACT: Events in the API

use Dancer2 appname => 'Act::Web::API';

my $schema = config->{'schema'};

get '/event/:event_id' => sub {
    my $conf_id  = param('conf_id');
    my $event_id = param('event_id');

    $event_id =~ /^[0-9]+$/ or pass;

    my $event = $schema->resultset('Event')->search(
        {
            event_id => $event_id,
            conf_id  => $conf_id,
        },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
    )->single() or send_error( 'No such event', 404 );

    return $event;
};

get '/event' => sub {
    my $conf_id = param('conf_id');
    my @events  = $schema->resultset('Event')->search(
        { conf_id      => $conf_id },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
    )->all;

    return { results => [@events] };
};

1;
