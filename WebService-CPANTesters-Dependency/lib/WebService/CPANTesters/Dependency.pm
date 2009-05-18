package WebService::CPANTesters::Dependency;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw/Class::Accessor::Fast/;

use Carp qw/croak/;
use LWP::UserAgent;
use URI::Template::Restrict;
use XML::LibXML::XPathContext;
use XML::LibXML::XPathExpression;

__PACKAGE__->mk_accessors(qw/module depth dependencies/);

sub new {
    my ($class, %args) = @_;
    my $tmpl = URI::Template::Restrict->new(
        q#http://deps.cpantesters.org/?{-join|;|module,perl,os,xml}#);
    my $uri = $tmpl->process(+{
        xml => $args->{xml} || 1,
        module => $args->{module} || croak "need to set module name",
        perl => $args->{perl} || '5.8.5',
        os => $args->{os} || 'Linux',
    });
    my $ua = LWP::UserAgent->new();
    my $response = $ua->get($uri);
    croak "can't get uri: $uri" unless ($response->is_success);
    my $parser = XML::LibXML->new();
    my $doc = $parser->parse_string($response->content);
    my $xpc = XML::LibXML::XPathContext->new($doc);
    bless { %args, _xpc => $xpc }, $class;
}

sub module { shift->{module} }

sub find {
    my $self = shift;
    my $compiled = XML::LibXML::XPathExpression->new('/cpandeps/dependency');
    my @nodes = $self->_xpc->find($compiled);
    $self->{_nodes} = \@nodes;
    return $self;
}

sub find_recursive {
}

sub depth {
}

sub dependencies {
    return @{ shift->{_nodes} };
}

1;
__END__

=head1 NAME

WebService::CPANTesters::Dependency -

=head1 SYNOPSIS

  use WebService::CPANTesters::Dependency;

=head1 DESCRIPTION

WebService::CPANTesters::Dependency is

=head1 AUTHOR

typomaster E<lt>naritoshi.hayashi@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
