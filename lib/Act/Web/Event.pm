package Act::Web::Event;
use Dancer2 appname => 'Act::Web';
set auto_page => 1;

use Act::Form;
use Act::Abstract;
use Act::Template::HTML;
use DateTime::Format::Pg;

my $act = Act::API->new( port => config->{'api_port'} );

# Act::Handler::Event::Show
get '/event/:event_id' => sub {
    my $event_id = param('event_id');
    $event_id =~ /^[0-9]$/ or pass;

    my $event = $act->event({ id => $event_id });
    $event->total > 0 or send_error( 404, 'Event not found' );

    my $template = Act::Template::HTML->new();

    $template->variables(
        %{$event},
        chunked_abstract => Act::Abstract::chunked( $event->abstract ),
    );

    return $template->process('events/show');
};

# alias to Act::Handler::Event::Edit
get '/newevent' => sub { forward '/editevent' };

# Act::Handler::Event::List
get '/editevent' => sub {
    var('user')->is_talks_admin or send_error( 404, 'Event not found' );

    my $event = verify_event()
        or send_error( 404, 'Event not found' );

    my ( $sdate, $edate, @dates ) = get_dates();

    # automatically computer the return URL
    my $return_url = create_return_url();

    # display the event submission form
    my $template = Act::Template::HTML->new();

    # XXX: config->{'rooms'} ?!?!
    #      (move to Act::API)
    $template->variables(
        return_url => $return_url,
        date       => \@dates, defined $event ? ( %{$event} ) : (),
        rooms      => {
            %{ config->{'rooms'} }, map {
                $_ => localize("room_$_")
            } qw<venue out sidetrack>,
        },
    );

    $template->process('event/add');
};

# alias Act::Handler::Event::Edit posting
post '/newevent' => sub { forward '/editevent' };

# Act::Handler::Event::Edit posting
post '/editevent' => sub {
    var('user')->is_talks_admin or send_error( 404, 'Event not found' );

    my $event = verify_event()
        or send_error( 404, 'Event not found' );

    my ( $sdate, $edate, @dates ) = get_dates();

    # automatically computer the return URL
    my $return_url = create_return_url();

    my $form = Act::Form->new(
      required    => [qw( title abstract )],
      optional    => [qw( url_abstract duration date time room delete )],
      constraints => {
         duration     => 'numeric',
         url_abstract => 'url',
         date         => 'date',
         time         => 'time',
         #room         => sub { exists $Config->{'rooms'}{$_[0]} or $_[0] =~ /^(?:out|venue|sidetrack)$/},
        room          => sub { die 'Not implemented yet' },
      }
    );

    my @errors;

    # validate form fields
    my $ok     = $form->validate(params);
    my $fields = $form->{'fields'};

    # apply default values
    $fields->{'duration'} ||= 0;

    # is the date in range?
    if ( ! inflate_date( $fields, $form, $sdate, $edate ) ) {
        # map errors
        $form->{invalid}{title}        && push @errors, 'ERR_TITLE';
        $form->{invalid}{abstract}     && push @errors, 'ERR_ABSTRACT';
        $form->{invalid}{duration}     && push @errors, 'ERR_DURATION';
        $form->{invalid}{url_abstract} && push @errors, 'ERR_URL_ABSTRACT';
        $form->{invalid}{date}         && push @errors, 'ERR_DATE';
        $form->{invalid}{time}         && push @errors, 'ERR_TIME';
        $form->{invalid}{period}       && push @errors, 'ERR_DATERANGE';
        $form->{invalid}{room}         && push @errors, 'ERR_ROOM';

        $template->variables( errors => \@errors );
    }

    ...

    my $template = Act::Template::HTML->new();

    # XXX: config->{'rooms'} ?!?!
    #      (move to Act::API)
    $template->variables(
        return_url => $return_url,
        date       => \@dates, defined $event ? ( %{$event} ) : (),
        rooms      => {
            %{ config->{'rooms'} }, map {
                $_ => localize("room_$_")
            } qw<venue out sidetrack>,
        },
    );

    $template->process('event/add');
};

sub verify_event {
    # get the event or skip
    # cannot edit non-existent events
    my $event;
    if ( my $event_id = param('event_id') ) {
        return $act->event({
            event_id => $event_id,
            conf_id  => param('conf_id'),
        });
    }

    return;
}

sub create_return_url {
    my $referer    = request->referer;
    my $return_url = param('return_url') || $referer
        if $referer =~ m{/schdule};
}

sub get_dates {
    my ( $sdate, $edate ) = $act->talks_start_end_dates;

    my @dates = ($sdate->clone->truncate(to => 'day' ));
    push @dates, $_
        while (($_ = $dates[-1]->clone->add( days => 1 ) ) < $edate );

    return ( $sdate, $edate, @dates );
}

sub inflate_date {
    my ( $fields, $form, $sdate, $edate );

    # check for errors first
    if ( $fields->{'date'}
      and $fields->{'time'}
      and ! exists $form->{'invalid'}{'date'}
      and ! exists $form->{'invalid'}{'time'} ) {

        return;
    }

    my $datetime = $form->{'datetime'} =
        DateTime::Format::Pg
        ->parse_timestamp("$fields->{'date'} $fields->{'time'}:00");

    if ( $datetime > $edate or $datetime < $sdate ) {
        $form->{'invalid'}{'period'} = 'invalid';
        return;
    }

    # it's okay
    return 1;
}

1;
