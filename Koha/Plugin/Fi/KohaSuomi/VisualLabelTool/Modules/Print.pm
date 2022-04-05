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
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields;
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database;
use C4::Context;
use Koha::Items;
use Koha::Libraries;
use Koha::AuthorisedValues;

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

sub db {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database->new;
}

sub labels {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels->new();
}

sub fields {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields->new();
}

sub printLabel {
    my ($self, $label_id, $test, $items) = @_;
    return $self->printTest($label_id) if $test;
    my @printLabels;
    foreach my $item (@{$items}) {
        my $label = $self->labels->getLabel($label_id);
        my $itemData = Koha::Items->find($item->{itemnumber});
        my ($biblio, $biblioitem, $marc) = $self->getBiblioData($itemData);
        my $data = {
            items => $itemData->unblessed,
            biblio => $biblio,
            biblioitems => $biblioitem,
            marc => $marc
        };

        my $valueLabel = $self->processFields($label, $data);
        push @printLabels, $valueLabel;
    }

    return \@printLabels;
}

sub printTest {
    my ($self, $label_id) = @_;
    my $label = $self->labels->getLabel($label_id);
    my $item = Koha::Items->search({}, {rows => 1})->next;
    my ($biblio, $biblioitem, $marc) = $self->getBiblioData($item);
    my $data = {
        items => $item->unblessed,
        biblio => $biblio,
        biblioitems => $biblioitem,
        marc => $marc
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
        if ($key eq 'items' || $key eq 'marc' || $key eq 'biblioitems' || $key eq 'biblio') {
            $field->{value} = $self->getDescriptionName($data, $key, $value);
        } else {
            $field->{value} = $self->getDescriptionName($data, $field->{name}, undef);
        }
        
    }

    foreach my $field (@{$label->{signum}->{fields}}) {
        my ($key, $value) = split /\./, $field->{name};
        if ($key eq 'items' || $key eq 'marc' || $key eq 'biblioitems' || $key eq 'biblio') {
            $field->{value} = $self->getDescriptionName($data, $key, $value);
        } else {
            $field->{value} = $self->getDescriptionName($data, $field->{name}, undef);
        }
        
    }

    return $label;

}

sub getBiblioData {
    my ($self, $item) = @_;

    return ($item->biblio->unblessed, $item->biblio->biblioitem->unblessed, $item->biblio->metadata->record);
}

sub getDescriptionName {
    my ($self, $data, $key, $value) = @_;
    
    my $response = $data->{$key}->{$value};
    return Koha::Libraries->find($response)->branchname if $value eq "homebranch";
    return $self->fields->signumYKL($data->{$key}->{'itemcallnumber'}) if $value eq "signumYKL";
    return $self->fields->location($data->{$key}->{'permanent_location'}, $data->{$key}->{'location'}) if $value eq "location";
    return $self->fields->signumLoc($data->{$key}->{'itemcallnumber'}) if $value eq "signumLoc";
    return $self->fields->signumHeading($data->{$key}->{'itemcallnumber'}) if $value eq "signumHeading";
    return $self->fields->marcField($data->{$key},$value) if $key eq "marc";
    return $self->fields->customField($data, $key) if !$value;
    return Koha::AuthorisedValues->search({ category => 'MTYPE', authorised_value => $response })->next->lib if $value eq 'itemtype';
    return $response;
}

sub getPrintQueue {
    my ($self, $borrowernumber, $printed) = @_;

    my $items = $self->db->getPrintQueue($borrowernumber, $printed);
    my $response;
    foreach my $item (@$items) {
        my $itemData = Koha::Items->find($item->{itemnumber})->unblessed;
        $itemData->{queue_id} = $item->{id};
        push @$response, $itemData;
    }

    return $response;
}

sub setPrintQueue {
    my ($self, $body) = @_;

    my @params = ($body->{borrowernumber}, $body->{itemnumber}, $body->{printed});
    $self->db->setPrintQueue(@params);
}

sub deleteFromPrintQueue {
    my ($self, $queue_id) = @_;
    
    $self->db->deletePrintQueueData($queue_id);
    
}

sub updatePrintQueue {
    my ($self, $body) = @_;

    my @params = ($body->{borrowernumber}, $body->{itemnumber}, $body->{printed}, $body->{queue_id});
    $self->db->updatePrintQueue(@params);
}

1;