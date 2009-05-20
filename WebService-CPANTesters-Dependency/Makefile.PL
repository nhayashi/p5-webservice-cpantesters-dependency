use inc::Module::Install;

name 'WebService-CPANTesters-Dependency';
all_from 'lib/WebService/CPANTesters/Dependency.pm';

requires 'Carp::Clan';
requires 'Class::Accessor::Fast';
requires 'LWP::UserAgent';
requires 'Perl::Version';
requires 'URI::Template::Restrict';
requires 'XML::LibXML';
requires 'XML::LibXML::XPathContext';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
