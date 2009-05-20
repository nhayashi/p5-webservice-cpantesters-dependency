package Test::WebService::CPANTesters::Dependency;

use strict;
use warnings;

use Carp;
use File::Slurp qw(slurp);
use FindBin;
use Test::Mock::LWP;
use Test::More;

sub init {
    my $class = shift;

    $Mock_request->set_isa('HTTP::Request');
    $Mock_response->set_isa('HTTP::Request');
    $Mock_ua->set_isa('LWP::UserAgent');
    $Mock_ua->set_always( get => $Mock_response );
}

sub set_module {
    my ($class, $module) = @_;

    my $module_path = $class->module_path($module);
    my $content = slurp($module_path);

    $Mock_response->set_always(
        content => $content
    );
}

sub module_path {
    my ($class, $module) = @_;
    File::Spec->catfile($FindBin::Bin, 'data', join('/', split '::' => $module) . '.xml');
}

1;
