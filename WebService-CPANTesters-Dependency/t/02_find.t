use lib qw(./t/lib);
use Test::More tests => 14 * 3;

use Test::WebService::CPANTesters::Dependency;
use WebService::CPANTesters::Dependency;

Test::WebService::CPANTesters::Dependency->init;

{
    my ($module, $perl, $os) = ('Catalyst::Runtime', '5.10.0', 'any OS');
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new(+{
        perl => $perl,
        os => $os
    });
    $dep->find($module);

    is($dep->perl, $perl, 'perl version');
    is($dep->os, $os, 'OS type');
    is($dep->module, $module, 'module name');

    is($dep->depth, 0, 'dependency depth');
    is($dep->warning, '', 'warnings element');
    is($dep->text_result, '', 'textresult element');
    is($dep->is_pure_perl, '?', 'ispureperl element');
    is($dep->total_results, 44, 'totalresults element');
    is($dep->passes, 44, 'passes element');
    is($dep->fails, 0, 'fails element');
    is($dep->unknowns, 0, 'unknowns element');
    is($dep->nas, 0, 'nas element');

    is($dep->is_core, 0, 'core module');
    isa_ok($dep->dependencies, 'List::Rubyish', 'dependencies object');
}

{
    my ($module, $perl, $os) = ('Moose', '5.8.5', 'Linux');
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new(+{
        perl => $perl,
        os => $os
    });
    $dep->find($module);

    is($dep->perl, $perl, 'perl version');
    is($dep->os, $os, 'OS type');
    is($dep->module, $module, 'module name');

    is($dep->depth, 0, 'dependency depth');
    is($dep->warning, '', 'warnings element');
    is($dep->text_result, '', 'textresult element');
    is($dep->is_pure_perl, '?', 'ispureperl element');
    is($dep->total_results, 0, 'totalresults element');
    is($dep->passes, '', 'passes element');
    is($dep->fails, '', 'fails element');
    is($dep->unknowns, '', 'unknowns element');
    is($dep->nas, '', 'nas element');

    is($dep->is_core, 0, 'core module');
    isa_ok($dep->dependencies, 'List::Rubyish', 'dependencies object');
}

{
    my ($module, $perl, $os) = ('Apache2::ASP', '5.9.6', 'Mac OS X');
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new(+{
        perl => $perl,
        os => $os
    });
    $dep->find($module);

    is($dep->perl, $perl, 'perl version');
    is($dep->os, $os, 'OS type');
    is($dep->module, $module, 'module name');

    is($dep->depth, 0, 'dependency depth');
    is($dep->warning, '', 'warnings element');
    is($dep->text_result, '', 'textresult element');
    is($dep->is_pure_perl, '?', 'ispureperl element');
    is($dep->total_results, 0, 'totalresults element');
    is($dep->passes, '', 'passes element');
    is($dep->fails, '', 'fails element');
    is($dep->unknowns, '', 'unknowns element');
    is($dep->nas, '', 'nas element');

    is($dep->is_core, 0, 'core module');
    isa_ok($dep->dependencies, 'List::Rubyish', 'dependencies object');
#    cmp_ok(scalar @$dep->dependencies, '==', 63, 'number of dependency modules');
}

