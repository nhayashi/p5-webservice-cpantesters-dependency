use lib qw(./t/lib);
#use Test::More tests => 1 * 1;
use Test::More qw(no_plan);

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
    my @deps = $dep->list();

    cmp_ok(@deps, '==', 60, 'number of dependency modules');
    is($deps[0]->module, 'Scalar::Util', 'module is Scalar::Util');
    is($deps[0]->depth, 1, 'depth is 1');
    is($deps[0]->warning, '', 'warning is empty');
    is($deps[0]->text_result, 'Core module', 'textresult is Core module');
    is($deps[0]->is_pure_perl, '?', 'ispureperl is ?');
    is($deps[0]->total_results, 0, 'totalresults is 0');
    is($deps[0]->is_core, 1, 'core module');

    note explain $deps[1]->dependencies;
}

=pod
{
    my ($module, $perl, $os) = ('Moose', '5.8.5', 'Linux');
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new(+{
        perl => $perl,
        os => $os
    });
}

{
    my ($module, $perl, $os) = ('Apache2::ASP', '5.9.6', 'Mac OS X');
    Test::WebService::CPANTesters::Dependency->set_module($module);

    diag("module: " . $module);

    my $dep = WebService::CPANTesters::Dependency->new(+{
        perl => $perl,
        os => $os
    });
}
=cut

