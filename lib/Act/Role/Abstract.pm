package Act::Role::Abstract;
use Moo::Role;

# turn talk:id / user:id into real talks/users
sub chunked_abstract {
    my ( $self, $conf_id, $abstract ) = @_;

    my $i = 0;
    return [
        map {
            my $t = { };
            if ( $i++ % 2 ) {
                my ($what, $id) = split ':';
                if ($what eq 'talk') {
                    my ($talk, $user) = $self->expand_talk( $conf_id, $id );
                    if ($talk) {
                        $t->{talk} = $talk;
                        $t->{user} = $user;
                    }
                    else {
                        $t->{text} = "talk:$id"; # non-existent talk
                    }
                }
                elsif ($what eq 'user') {
                    my $user = $self->expand_user( $conf_id, $id );
                    if ($user) {
                        $t->{user} = $user;
                    }
                    else { # non-existent user
                        $t->{text} = "user:$id";
                    }
                }
                else { $t->{text} = $_ }
            }
            else { $t->{text} = $_ }
            $t;
          } split /((?:talk|user):\d+)/,
        $_[0]
    ];

}

sub _expand_talk {
    my ( $self, $talk_id, $conf_id ) = @_;

    my $talk = $self->talk({
        talk_id => $talk_id,
        conf_id => $conf_id,
    });

    $talk or return $talk;

    my $user = $self->user({
        user_id => $talk->user_id,
        conf_id => $conf_id,
    });

    return ( $talk, $user );
}

sub expand_user {
    my ( $self, $conf_id, $user_info ) = @_;

    my %args = ( user_id => $user_info );

    if ( $user_info !~ /^\d+/ ) {
        my @id = split /\s+/, $user_info, 2;
        if ( @id == 2 ) {
            %args = ( first_name => $id[0], last_name => $id[1] );
        } else {
            %args = ( nick_name => $user_info );
        }
    }

    my $user = $self->user({
        %args,
        conf_id => $conf_id,
    });

    return $user;
}

# this has been adjusted to not crash :)
sub expand_news
{
    die 'Not implemented yet';
    my $news_id = shift;
    my $news;
    require Act::Handler::News::Fetch;
    if ($news_id && $news_id =~ /^\d+$/) {
        $news = Act::Handler::News::Fetch::fetch(1, $news_id);
        $news = $news->[0] if @$news;
    }
    return $news;
}
1;

__END__

=head1 NAME

Act::Abstract - event/talk abstract utilities

=head1 SYNOPSIS

    use Act::Abstract;
    my $chunked = Act::Abstract::chunked($talk->abstract);
    my ($talk, $user) = Act::Abstract::expand_talk(42);
    my $user = Act::Abstract:expand_user(42);

=cut
