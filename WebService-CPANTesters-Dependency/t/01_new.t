use strict;
use Test::More tests => 1;

use WebService::CPANTesters::Dependency;

my $deps = WebService::CPANTesters::Dependency->new();

isa_ok($deps, 'WebService::CPANTesters::Dependency');

