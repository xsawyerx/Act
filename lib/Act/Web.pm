package Act::Web;
# ABSTRACT: Web interface to Act

use Danecr2;
use Class::Load 'load_class';

my @classes = qw<
    Act::Web::Event
>;

sub setup {
    load_class($_) && $_->import for @classes;
}

1;
