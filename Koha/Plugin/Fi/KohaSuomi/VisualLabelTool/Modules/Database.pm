package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database;

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
use C4::Context;

=head new

    my $labels = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels->new($params);

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {};
    $self->{_params} = $params;
    bless($self, $class);
    return $self;

}

sub plugin {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool->new;
}

sub labels {
    my ($self) = @_;
    return $self->plugin->get_qualified_table_name('labels');
}

sub fields {
    my ($self) = @_;
    return $self->plugin->get_qualified_table_name('fields');
}

sub dbh {
    my ($self) = @_;
    return C4::Context->dbh;
}

sub getLabelsData {
    my ($self) = @_;

    my $sth = $self->dbh->do("SELECT * FROM ".$self->labels.";");
    return $sth->fetchrow_hashref;
}

sub getLabelData {
    my ($self, $id) = @_;

    my $sth = $self->dbh->do("SELECT * FROM ".$self->labels." WHERE id = ?;", undef, $id);
    return $sth->fetchrow_hashref;

}

sub setLabelData {
    my ($self, $params) = @_;

    my $sth=$self->dbh->prepare("INSERT INTO ".$self->labels." (name,labelcount,width,height,top,bottom,left,right) VALUES (?,?,?,?,?,?,?,?)");
    return $sth->execute($params);
    
}

sub getFieldData {
    my ($self, $label_id) = @_;

    my $sth = $self->dbh->do("SELECT * FROM ".$self->fields." where label_id = ?;", undef, $label_id);
    return $sth->fetchrow_hashref;

}

sub setFieldData {
    my ($self, $params) = @_;

    my $sth=$self->dbh->prepare("INSERT INTO ".$self->fields." (label_id,name,type,top,left,fontsize) VALUES (?,?,?,?,?,?)");
    return $sth->execute($params);

}


1;