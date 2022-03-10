package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print;

# Copyright 2022 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Carp;
use Scalar::Util qw( blessed );
use Try::Tiny;
use JSON;
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool;
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels;
use C4::Context;
use Koha::Items;
use Koha::Libraries;

=head new

    my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new($params);

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {};
    $self->{_params} = $params;
    bless($self, $class);
    return $self;

}

sub labels {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels->new();
}

sub printLabel {
    my ($self, $label_id, $test) = @_;
    my $label = $self->labels->getLabel($label_id);
    return $self->printTest($label) if $test;
    return;
}

sub printTest {
    my ($self, $label) = @_;

    my $item = Koha::Items->search({}, {rows => 1})->next;
    my ($biblio, $biblioitem) = $self->getBiblioData($item);
    my $data = {
        items => $item->unblessed,
        biblio => $biblio,
        biblioitems => $biblioitem
    };

    my @testLabels;

    for (my $i = 0; $i < $label->{labelcount}; $i++) {
        my $valueLabel = $self->processFields($label, $data);
        push @testLabels, $valueLabel;
    }

    return \@testLabels;
}

sub processFields {
    my ($self, $label, $data) = @_;
 
    foreach my $field (@{$label->{fields}}) {
        my ($key, $value) = split /\./, $field->{name};
        $field->{value} = $self->getDescriptionName($data, $key, $value);
        
    }

    return $label;

}

sub getBiblioData {
    my ($self, $item) = @_;

    return ($item->biblio->unblessed, $item->biblio->biblioitem->unblessed);
}

sub getDescriptionName {
    my ($self, $data, $key, $value) = @_;

    my $response = $data->{$key}->{$value};
    return Koha::Libraries->find($response)->branchname if $value eq "homebranch";
    return $response;
}

1;