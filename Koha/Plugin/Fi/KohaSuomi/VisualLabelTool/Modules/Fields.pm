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
use Text::ParseWords;
use Koha::AuthorisedValues;
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
    push @$columns, $self->getMarcFields();
    push @$columns, 'custom';

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
        'items.barcodevalue', 
        'items.homebranch',
        'items.branchname', 
        'items.itemcallnumber', 
        'items.location',
        'items.permanent_location',
        'items.ccode', 
        'items.cn_source', 
        'items.cn_sort', 
        'items.enumchron',
        'items.signumYKL',
        'items.signumLoc',
        'items.signumHeading'
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
    return ('marc.title',
    'marc.author',
    'marc.unititle',
    'marc.description',
    'marc.publication',
    'marc.volume'
    );
}

sub signumHeading {
    my ($self, $itemcallnumber) = @_;

    return $self->yklSecond($itemcallnumber) unless ($self->yklSecond($itemcallnumber) =~/-*\d+\.\d+/);
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[2]) ? $parts[2] : undef;
}

sub signumLoc {
    my ($self, $itemcallnumber) = @_;

    return $self->yklFirst($itemcallnumber) unless ($self->yklFirst($itemcallnumber) =~/-*\d+\.\d+/);
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[2]) ? $parts[2] : undef;
}

sub location {
    my ($self, $permanent_location, $location) = @_;

    my $locCode = $permanent_location || $location;
    return '' if(not($locCode));

    my $av = Koha::AuthorisedValues->search({
        category => 'LOC',
        authorised_value => $locCode
    });
    $av = $av->count ? $av->next->lib : '';
    return $av;
}

sub signumYKL {
    my ($self, $itemcallnumber) = @_;
    
    return $self->yklFirst($itemcallnumber) if ($self->yklFirst($itemcallnumber) =~/-*\d+\.\d+/);
    return $self->yklSecond($itemcallnumber);
}


sub yklSecond {
    my ($self, $itemcallnumber) = @_;
    #PKM 84.4 MAG
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[1]) ? $parts[1] : undef;
}

sub yklFirst {
    my ($self, $itemcallnumber) = @_;
    #84.2 SLO PK N
    my @parts = split(/\s+/, $itemcallnumber);
    return ($parts[0]) ? $parts[0] : undef;
}

sub customField {
    my ($self, $data, $field) = @_;

    my $ors = $self->_splitToLogicSegments($field);

    ##Evaluate 'or'-segments in order.
    foreach my $or (@$ors) {
        my $payload = $self->_evalSegment($or, $data);
        my $val = join(' ', @$payload);
        return $val if $val;
    }
}

sub marcField {
    my ($self, $data, $field) = @_;

    if ($field eq 'title') {
        return $self->marcTitle($data);
    }

    if ($field eq 'author') {
        return $self->marcAuthor($data);
    }

    if ($field eq 'unititle') {
        return $self->marcUnititle($data);
    }

    if ($field eq 'description') {
        return $self->marcDescription($data);
    }

    if ($field eq 'publication') {
        return $self->marcPublication($data);
    }

    if ($field eq 'volume') {
        return $self->marcVolume($data);
    }
}

sub marcTitle {
    my ($self, $record) = @_;

    my $title = '';
    if (my $f245 = $record->field('245')) {
        my $sfA = $f245->subfield('a');
        my $sfB = $f245->subfield('b');
        my $sfN = $f245->subfield('n');
        my $sfP = $f245->subfield('p');

        $title .= $sfA if $sfA;
        $title .= $sfB if $sfB;
        $title .= $sfN if $sfN;
        $title .= $sfP if $sfP;
        $title = 'no subfields in $245' unless $title;
    }
    elsif (my $f111 = $record->field('111')) {
        my $sfA = $f111->subfield('a');
        $title = $sfA;
    }
    elsif (my $f130 = $record->field('130')) {
        my $sfA = $f130->subfield('a');
        $title = $sfA;
    }
    return $title;
}

sub marcAuthor {
    my ($self, $record) = @_;

    my $author = '';

    if ($record->subfield('942','i')) {
        $author .= $record->subfield('942','i');
    }
    elsif ($record->subfield('100','a')) {
        $author .= $record->subfield('100','a');
    }

    if ($record->subfield('100','c')) {
        $author .= $record->subfield('100','c');
    }
    elsif ($record->subfield('110','a')) {
        $author .= $record->subfield('110','a');
    }
    elsif ($record->subfield('111','a')) {
        $author .= $record->subfield('111','a');
    }

    return $author;
}

sub marcUnititle {
    my ($self, $record) = @_;

    my $unititle = '';
    $unititle .= $record->subfield('130','a') if $record->subfield('130','a');
    $unititle .= $record->subfield('130','l') if $record->subfield('130','l');
    return $unititle;
}

sub marcDescription {
    my ($self, $record) = @_;

    my $value = '';
    $value .= $record->subfield('300','a') if $record->subfield('300','a');
    $value .= $record->subfield('300','e') if $record->subfield('300','e');
    $value .= $record->subfield('347','b') if $record->subfield('347','b');
    return $value;
}

sub marcPublication {
    my ($self, $record) = @_;

    my $value = '';
    $value .= $record->subfield('260','c') || $record->subfield('264','c');
    return $value;
}

sub marcVolume {
    my ($self, $record) = @_;

    my $value = '';
    $value .= $record->subfield('262','a') || $record->subfield('049','a');
    return $value;
}

sub _splitToLogicSegments {
    my ($self, $directive) = @_;

    my @tokens = Text::ParseWords::quotewords('\s+', 'keep', $directive);
    my @ors;
    my $segments = [];
    foreach my $token (@tokens) {
        if ($token =~ /^(or|\|\|)$/) { #Split using '||' or 'or'
            push(@ors, $segments);
            $segments = [];
        }
        else {
            push(@$segments, $token) if (not($token =~ /^(and|&&|\.|\+)$/));
        }
    }
    #if the last token wasn't a or-clause, add the remainder to logic segments. This way we prevent adding a trailing or two times.
    if (not($tokens[scalar(@tokens)-1] =~ /^or|\|\|$/)) {
        push(@ors, $segments);
    }

    return \@ors;
    ##First split to 'or'-segments
    #my @ors = split(/ or | \|\| /, $directive); #Split using '||' or 'or'
    #return \@ors;
}

sub _evalSegment {
    my ($self, $or, $data) = @_;
    my @payload; #Collect results of source definition matchings here.
    foreach my $op (@$or) {
        if (my $marcSel = $self->_isMARCSelector($op)) {
            my $val = $self->_getMARCValue($marcSel, $data->{marc});
            push(@payload, $val) if $val;
        }
        elsif (my $dbSel = $self->_isDBSelector($op)) {
            my $val = $self->_getDBSelectorValue($dbSel, $data);
            push(@payload, $val) if $val;
        }
        elsif (my $text = $self->_isText($op)) {
            push(@payload, $text) if $text;
        }
        else {
            my @cc = caller(0);
            die $cc[3]."($op):> Couldn't parse this source definition '$op'";
        }
    }
    return \@payload;
}

sub _getMARCValue {
    my ($self, $selector, $record) = @_;

    my @fields = $record->field( $selector->{field} );
    foreach my $f (@fields) {
        my $sf = $f->subfield( $selector->{subfield} );
        return $sf if $sf;
    }
    return undef;
}

sub _isMARCSelector {
    my ($self, $op) = @_;
    if ($op =~ /^\s*(\d{3})\$(\w)\s*$/) { #Eg. 245$a
        return {field => "$1", subfield => "$2"};
    }
    return undef;
}
sub _isDBSelector {
    my ($self,$op) = @_;
    if ($op =~ /^\s*(\w+)\.(\w+)\s*$/) { #Eg. biblio.3_little_musketeers
        return {table => "$1", column => "$2"};
    }
    return undef;
}
sub _isText {
    my ($self, $op) = @_;
    if ($op =~ /^"(.+)"$/) { #Eg. biblio.3_little_musketeers
        return $1;
    }
    return undef;
}

sub _getDBSelectorValue {
    my ($self, $selector, $dbData) = @_;
    my $table = $dbData->{$selector->{table}};
    unless ($table) {
        my @cc = caller(0);
        die $cc[3]."():> data source requests table '".$selector->{table}."', but that table is not available.";
    }
    unless (exists($table->{ $selector->{column} })) {
        my @cc = caller(0);
        die $cc[3]."():> data source requests table '".$selector->{table}."' and column '".$selector->{column}."', but that column is not available.";
    }
    return $table->{ $selector->{column} };
}

1;