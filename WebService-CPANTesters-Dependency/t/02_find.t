use lib qw(./t/lib);
use Test::More tests => 4 * 2;

use Test::WebService::CPANTesters::Dependency;
use WebService::CPANTesters::Dependency;

Test::WebService::CPANTesters::Dependency->init;

{
    my $module = 'Catalyst::Runtime';
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new();
    $dep->find($module);

    is($dep->module, $module, 'module name');
    is($dep->perl, '5.10.0', 'perl version');
    is($dep->depth, 0, 'dependency depth');
    is($dep->os, 'any OS', 'OS type');
}

{
    my $module = 'Moose';
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new();
    $dep->find($module);

    is($dep->module, $module, 'module name');
    is($dep->perl, '5.8.5', 'perl version');
    is($dep->depth, 0, 'dependency depth');
    is($dep->os, 'Linux', 'OS type');
}

