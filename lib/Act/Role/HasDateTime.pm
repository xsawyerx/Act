package Act::Role::HasDateTime;
# ABSTRACT: A role that automatically expands DateTime objects

use Moo::Role;
use DateTime::Format::Pg;

# FIXME: around should be used here instead
sub BUILDARGS {
    my $class = shift;
    my %args  = @_ == 1 ? %{ $_[0] } : @_;

    # expand datetime
    if ( defined $args{'datetime'} ) {
        $args{'datetime'} = DateTime::Format::Pg->parse_datetime(
            $args{'datetime'}
        );
    }

    return \%args;
}

1;
