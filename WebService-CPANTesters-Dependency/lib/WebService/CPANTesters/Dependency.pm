package WebService::CPANTesters::Dependency;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw/Class::Accessor::Fast/;

use Carp qw/croak/;
use LWP::UserAgent;
use Perl::Version;
use URI::Template::Restrict;
use XML::LibXML::XPathContext;
use Smart::Comments;

__PACKAGE__->mk_accessors(qw/perl os module depth start_depth dependencies/);

our ($PERL_VERSION) = Perl::Version->new($])->normal =~ m/^v(.*)$/;
our $ENDPOINT_TMPL  = URI::Template::Restrict->new(
    q#http://deps.cpantesters.org/?{-join|;|module,perl,os,xml}#
);

sub new {
    my ($class, $args) = @_;

    $args->{dependencies} ||= [];
    $args->{depth} ||= 0;
    $args->{start_depth} ||= 0;

    return $class->SUPER::new($args);
}

sub find {
    my ($self, $module, $args) = @_;

    croak(q|Please specifiy module name.|) unless ($module);

    $args ||= +{};
    $args = +{
        perl => $PERL_VERSION,
        os => 'Linux',
        %$args,
        xml => 1,
        module => $module,
    };

    ### $args
    
    my $uri = $ENDPOINT_TMPL->process($args);

    ### $uri
    
    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get($uri);

    return unless ($res->is_success);

    my $parser = XML::LibXML->new;
    my $doc = $parser->parse_string($res->content);
    my $xpc = XML::LibXML::XPathContext->new($doc);

    $self->module($xpc->findvalue(q|//cpandeps/module|));
    $self->perl(Perl::Version->new($xpc->findvalue(q|//cpandeps/perl|)));
    $self->os($xpc->findvalue(q|//cpandeps/os|));

    my @dep_nodes = $xpc->findnodes(q|//cpandeps/dependency|);
    my $dep_self_node = shift @dep_nodes;

    for my $dep_node (@dep_nodes) {
        next ($dep_node->findvalue(q|./textresult|) !~ /^core module$/i);
        push @{$self->{dependencies}}, $dep_node->findvalue(q|./module|);
    }
}

sub find_recursive {
    my ($self, $module, $args) = @_;

    croak(q|Please specifiy module name.|) unless ($module);

    $args ||= +{};
    $args = +{
        perl => $PERL_VERSION,
        os => 'Linux',
        %$args,
        xml => 1,
        module => $module,
    };

    ### $args
    
    my $uri = $ENDPOINT_TMPL->process($args);

    ### $uri
    
    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get($uri);

    return unless ($res->is_success);

    my $parser = XML::LibXML->new;
    my $doc = $parser->parse_string($res->content);
    my $xpc = XML::LibXML::XPathContext->new($doc);

    $self->module($xpc->findvalue(q|//cpandeps/module|));
    $self->perl(Perl::Version->new($xpc->findvalue(q|//cpandeps/perl|)));
    $self->os($xpc->findvalue(q|//cpandeps/os|));

    my @dep_nodes = $xpc->findnodes(q|//cpandeps/dependency|);
    my $dep_self_node = shift @dep_nodes;

    my %dep_module;
    for my $dep_node (@dep_nodes) {
        next ($dep_node->findvalue(q|./textresult|) !~ /^core module$/i);

        my $module = $dep_node->findvalue(q|./module|);
        my $depth = $dep_node->findvalue(q|./depth|);
        $dep_module{$module} = 1;

        my $child = WebService::CPANTesters::Dependency->new(+{
            start_depth => $depth,
        });
        $child->find_recursive($module);
    }
    $self->dependencies([keys %dep_module]);
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
