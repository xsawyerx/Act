package Act::Web;
# ABSTRACT: Web interface to Act

use Dancer2;
use Class::Load 'load_class';
use Act::API;

my @classes = qw<
    Act::Web::Event
>;

sub setup {
    my $class = shift;
    my %opts  = @_;

    # set optional configuration override
    set $_ => $opts{$_} for keys %opts;

    # create Act::API object
    set _act_api_object => Act::API->new( config->{'api'} );

    # force all of the paths under this prefix
    prefix '/:conf_id' => sub {
        load_class($_) && $_->import for @classes;
    };
}

1;
