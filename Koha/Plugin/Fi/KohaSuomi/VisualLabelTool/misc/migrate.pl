#!/usr/bin/perl

# Copyright 2022 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use
  CGI; # NOT a CGI script, this is just to keep C4::Templates::gettemplate happy
use C4::Context;
use Modern::Perl;
use Getopt::Long;
use Koha::Plugins;
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool;
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database;
use JSON;

my $dbh = C4::Context->dbh;
my $sheets = $dbh->selectall_arrayref("SELECT * FROM label_sheets", { Slice => {} });
my $db = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database->new();
foreach my $sheet (@$sheets) {
    my $json = from_json($sheet->{sheet});
    my $name = $json->{name};
    my ($type) = $json->{name} =~ /(\d+)/;
    my $label_count = $type;
    $type = 'roll' unless $type;
    $label_count = '1' unless $type;
    my @label = ($name, $type, $label_count, '90mm', '40mm', undef, undef, undef, undef, '20mm', '20mm', undef, undef, undef, undef);
    my $label_id = $db->setLabelData(@label);
    my $elements = $json->{items}[0]->{regions}[0]->{elements};
    foreach my $element (@$elements) {
        my $top = $element->{position}->{top}+0;
        my $left = $element->{position}->{left}+0;
        my ($key, $value) = split /\./, $element->{dataSource};
        $key = 'items' if $key eq 'item';
        my $source = $element->{dataSource};
        $source = $key.'.'.$value if $key && $value;
        $source = 'biblioitems.itemtype' if $source eq 'itemtype()';
        $source = 'items.signumLoc' if $source eq 'oplibLabel()';
        $source = 'items.homebranch' if $source eq 'homebranch.branchname';
        $source = 'items.signumYKL' if $source eq 'yklVaara()' || $source eq 'yklKyyti()';
        $source = 'items.location' if $source eq 'location()';
        my @params = (
            $label_id,
            $source,
            'label',
            $top * 0.245.'mm',
            $left * 0.245.'mm',
            '0mm',
            $element->{fontSize}.'px',
            'Arial',
            'normal'
        );
        $db->setFieldData(@params);
    }
    my @signum1 = (
        $label_id,
        'items.signumYKL',
        'signum',
        '1mm',
        '1mm',
        '0mm',
        '14px',
        'Arial',
        'normal'
    );
    $db->setFieldData(@signum1);
    my @signum2 = (
        $label_id,
        'items.signumHeading',
        'signum',
        '6mm',
        '1mm',
        '0mm',
        '14px',
        'Arial',
        'normal'
    );
    $db->setFieldData(@signum2);
    my @signum3 = (
        $label_id,
        'items.signumLoc',
        'signum',
        '11mm',
        '1mm',
        '0mm',
        '14px',
        'Arial',
        'normal'
    );
    $db->setFieldData(@signum3);   
}

