#!perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Dancer2;
use Act::Web;
use Act::Web::API;
use Plack::Builder;

my ( $api, $web ) = @{ config() }{qw<api_interface web_interface>};

builder {
    if ($api) {
        load_class('Act::Web::API');
        Act::Web::API->import();
        Act::Web::API->setup();
        mount $api => Act::Web::API->to_app;
    }

    if ($web) {
        load_class('Act::Web');
        Act::Web->import();
        Act::Web->setup();
        mount $web => Act::Web->to_app;
    }
};
