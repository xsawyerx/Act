package Act::Web::API;
# ABSTRACT: Web API interface to the Act system

use Dancer2;
use Act::Schema;
use Class::Load 'load_class';

my @classes = qw<
    Act::Web::API::Event
>;

set serializer => 'JSON';

hook before => sub {
    my $sid = ''; # XXX: where is this from again?
    var user => config->{'schema'}->resultset('User')->find(
        { session_id   => $sid },
        { result_class => 'DBIx::Class::ResultClass::HashRefInflator' },
    );
};

sub setup {
    my $class = shift;
    my %opts  = @_;

    $opts{'schema'} ||= Act::Schema->connect( config->{'dsn'} );
    set $_ => $opts{$_} for keys %opts;

    # force all of the paths under this prefix
    prefix '/:conf_id' => sub {
        load_class($_) && $_->import for @classes;
    };
}

1;
