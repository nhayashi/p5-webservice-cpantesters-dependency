package WebService::CPANTesters::Dependency;

use strict;
use warnings;

our $VERSION = '0.01';

use base qw/Class::Accessor::Fast/;

use Carp::Clan qw/croak/;
use List::Rubyish;
use LWP::UserAgent;
use Perl::Version;
use URI::Template::Restrict;
use XML::LibXML;
use XML::LibXML::XPathContext;

__PACKAGE__->mk_accessors(qw/
    perl
    os
    module
    depth
    warning
    text_result
    is_pure_perl
    total_results
    passes
    fails
    unknowns
    nas
    is_core
    dependencies
    chance_of_success
    debug
/);

our ($PERL_VERSION) = Perl::Version->new($])->normal =~ m/^v(.*)$/;
our $ENDPOINT_TMPL  = URI::Template::Restrict->new(
    q#http://deps.cpantesters.org/?{-join|;|module,perl,os,xml}#
);

sub new {
    my ($class, $args) = @_;

    $args->{dependencies} ||= List::Rubyish->new([]);
    $args->{depth} ||= 0;

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

    my $uri = $ENDPOINT_TMPL->process($args);

    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get($uri);

    return unless ($res->is_success);

    my $parser = XML::LibXML->new;
    my $doc = $parser->parse_string($res->content);
    my $xpc = XML::LibXML::XPathContext->new($doc);

    $self->module($xpc->findvalue(q|//cpandeps/module|));
    $self->perl(Perl::Version->new($xpc->findvalue(q|//cpandeps/perl|)));
    $self->os($xpc->findvalue(q|//cpandeps/os|));
    $self->chance_of_success(
        $xpc->findvalue(q|//cpandeps/chanceofsuccess|) =~ /(\d+%)/);
    $self->debug($xpc->findvalue(q|//cpandeps/debug|));

    my @dep_nodes = $xpc->findnodes(q|//cpandeps/dependency|);
    my $dep_node = shift @dep_nodes;
    my $dep_args =
        $self->_parse_node($dep_node, $self->_findvalue($dep_node, q|./depth|));

    for my $attr (keys %$dep_args) {
        next if ($attr eq 'module');
        $self->$attr($dep_args->{$attr});
    }

    for (my $i = 0; $i < $#dep_nodes + 1; $i++) {
        if ($self->_parse($self, \@dep_nodes, \$i)) {
            $i--;
        }
    }

    1;
}

sub _parse {
    my ($self, $parent, $dep_nodes, $idx_ref) = @_;

    my $dep_node = $dep_nodes->[$$idx_ref];
    return unless ($dep_node);

    my $self_depth = $self->_findvalue($dep_node, q|./depth|);
    return unless ($self_depth > $parent->depth);

    my $dep_args = $self->_parse_node($dep_node, $self_depth);
    return unless ($dep_args);
    
    my $dependency = WebService::CPANTesters::Dependency->new($dep_args);
    $parent->dependencies->push($dependency);

    ${$idx_ref}++;
    while ($self->_parse($dependency, $dep_nodes, $idx_ref)) {
    }

    return 1;
}

sub _parse_node {
    my ($self, $dep_node, $self_depth) = @_;
    
    my $dep_args = +{
        module        => $self->_findvalue($dep_node, q|./module|),
        depth         => $self_depth,
        warning       => $self->_findvalue($dep_node, q|./warning|),
        text_result   => $self->_findvalue($dep_node, q|./textresult|),
        is_pure_perl  => $self->_findvalue($dep_node, q|./ispureperl|),
        total_results => $self->_findvalue($dep_node, q|./totalresults|),
        passes        => $self->_findvalue($dep_node, q|./passes|),
        fails         => $self->_findvalue($dep_node, q|./fails|),
        unknowns      => $self->_findvalue($dep_node, q|./unknowns|),
        nas           => $self->_findvalue($dep_node, q|./nas|),
    };

    $dep_args->{is_core} = (defined $dep_args->{text_result} && $dep_args->{text_result} eq 'Core module') ? 1 : 0;

    return $dep_args;
}

sub _findvalue {
    my ($self, $node, $xpath_exp) = @_;
    my $ret = $node->findvalue($xpath_exp);
    defined $ret ? $ret : undef;
}

sub list {
    my ($self, $is_sort, $parent, $ret, $deps) = @_;
    $is_sort ||= 0;
    $parent  ||= $self;
    $ret     ||= [];
    $deps    ||= $parent->dependencies;

    for my $dep (@{$deps->to_a}) {
        if ($is_sort) {
            if (scalar @{$dep->dependencies} <= 0) {
                push(@$ret, $dep);
            }
            $self->list($is_sort, $dep, $ret, $dep->dependencies);
            if (scalar @{$dep->dependencies} > 0) {
                push(@$ret, $dep);
            }
        } else {
            push(@$ret, $dep);
            $self->list($is_sort, $dep, $ret, $dep->dependencies);
        }
    }

    return wantarray ? @$ret : $ret;
}

1;
__END__

=head1 NAME

WebService::CPANTesters::Dependency - Frontend deps.cpantesters.org WebAPI

=head1 SYNOPSIS

  use YAML;
  use WebService::CPANTesters::Dependency;
  
  my $dep = WebService::CPANTesters::Dependency->new;
  $dep->find(q|Catalyst::Runtime|);
  local $, = "\n";
  print map { sprintf("%s%s", "  " x $_->depth, $_->module) } $dep->list;

=head1 DESCRIPTION

WebService::CPANTesters::Dependency is deps.cpantesters.org WebAPI frontend.

=head1 AUTHOR

typomaster E<lt>naritoshi.hayashi@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
