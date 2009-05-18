use strict;
use Test::More tests => 1;

use WebService::CPANTesters::Dependency;

my $deps = WebService::CPANTesters::Dependency->new(+{
    module => 'Catalyst::Runtime',
    perl => '5.8.5',
    os => 'Linux',
    xml => 1,
});
$deps->find;

isa_ok($deps, 'WebService::CPANTesters::Dependency');

