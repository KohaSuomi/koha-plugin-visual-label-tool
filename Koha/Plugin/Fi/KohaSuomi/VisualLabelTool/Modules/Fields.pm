package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields;

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
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database;
use C4::Context;
use Koha::Items;
use Koha::Database;

=head new

    my $fields = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields->new($params);

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

sub listFields {
    my ($self) = @_;

    my $columns;
    push @$columns, $self->getItem();
    push @$columns, $self->getBiblio();
    push @$columns, $self->getBiblioItem();

    return $columns;
}

sub deleteField {
    my ($self, $field_id) = @_;
    
    $self->db->deleteFieldData($field_id);
    
}

sub getItem {
    my ($self) = @_;

    return (
        'items.barcode', 
        'items.homebranch', 
        'items.itemcallnumber', 
        'items.permanent_location', 
        'items.ccode', 
        'items.cn_source', 
        'items.cn_sort', 
        'items.enumchron'
    );
}

sub getBiblio {
    my ($self) = @_;
    return (
        'biblio.author', 
        'biblio.title', 
        'biblio.medium', 
        'biblio.subtitle', 
        'biblio.part_number', 
        'biblio.part_name', 
        'biblio.unititle', 
        'biblio.serial', 
        'biblio.seriestitle', 
        'biblio.copyrightdate'
    );
}

sub getBiblioItem {
    my ($self) = @_;
    return (
        'biblioitems.volume',
        'biblioitems.number',
        'biblioitems.itemtype',
        'biblioitems.isbn',
        'biblioitems.issn',
        'biblioitems.ean',
        'biblioitems.publicationyear',
        'biblioitems.publishercode',
        'biblioitems.volumedate',
        'biblioitems.volumedesc',
        'biblioitems.collectiontitle',
        'biblioitems.collectionissn',
        'biblioitems.collectionvolume',
        'biblioitems.editionstatement',
        'biblioitems.editionresponsibility',
        'biblioitems.illus',
        'biblioitems.pages',
        'biblioitems.size',
        'biblioitems.place',
        'biblioitems.lccn',
        'biblioitems.cn_source',
        'biblioitems.cn_class',
        'biblioitems.cn_item',
        'biblioitems.cn_suffix',
        'biblioitems.cn_sort',
        'biblioitems.agerestriction'
    );
}

sub getMarcFields {
    my ($self) = @_;
    return ()
}

1;