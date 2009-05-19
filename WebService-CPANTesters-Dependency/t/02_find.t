use strict;
use Test::More tests => 2;

use WebService::CPANTesters::Dependency;

my $dep = WebService::CPANTesters::Dependency->new();
$dep->find('Catalyst::Runtime');

is($dep->{module}, 'Catalyst::Runtime');
is($dep->{depth}, 0);

