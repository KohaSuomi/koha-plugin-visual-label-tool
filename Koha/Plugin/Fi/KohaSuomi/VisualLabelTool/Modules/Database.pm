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

    my $labels = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database->new($params);

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

sub printed {
    my ($self) = @_;
    return $self->plugin->get_qualified_table_name('printed');
}

sub printQueue {
    my ($self) = @_;
    return $self->plugin->get_qualified_table_name('print_queue');
}

sub dbh {
    my ($self) = @_;
    return C4::Context->dbh;
}

sub getLabelsData {
    my ($self) = @_;

    my $sth = $self->dbh->prepare("SELECT * FROM ".$self->labels." order by name asc;");
    $sth->execute();
    return $sth->fetchall_arrayref({});
}

sub getLabelData {
    my ($self, $id) = @_;

    my $sth = $self->dbh->prepare("SELECT * FROM ".$self->labels." WHERE id = ?;");
    $sth->execute($id);
    return $sth->fetchrow_hashref;

}

sub setLabelData {
    my ($self, @params) = @_;
    
    my $sth=$self->dbh->prepare("INSERT INTO ".$self->labels." 
    (name,type,labelcount,width,height,top,bottom,`left`,`right`,signum_width,signum_height,signum_top,signum_bottom,signum_left,signum_right) 
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
    $sth->execute(@params);
    return $sth->{mysql_insertid};
    
}

sub updateLabelData {
    my ($self, @params) = @_;
    
    my $sth=$self->dbh->prepare("UPDATE ".$self->labels." SET 
    name = ?,type = ?,labelcount = ?,width = ?,height = ? ,top = ?,bottom = ?,`left` = ?,`right` = ?,signum_width = ?,signum_height = ?,signum_top = ?,signum_bottom = ?,signum_left = ?,signum_right = ? 
    WHERE id = ?;");
    return $sth->execute(@params);
    
}

sub deleteLabelData {
    my ($self, $id) = @_;

    my $sth = $self->dbh->prepare("DELETE FROM ".$self->labels." WHERE id = ?;");
    return $sth->execute($id);

}

sub getFieldData {
    my ($self, $label_id) = @_;

    my $sth = $self->dbh->prepare("SELECT * FROM ".$self->fields." where label_id = ?;");
    $sth->execute($label_id);
    return $sth->fetchall_arrayref({});

}

sub setFieldData {
    my ($self, @params) = @_;

    my $sth=$self->dbh->prepare("INSERT INTO ".$self->fields." (label_id,name,type,top,`left`,`right`,`bottom`,fontsize, fontfamily, fontweight, whitespace, height) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
    return $sth->execute(@params);

}

sub updateFieldData {
    my ($self, @params) = @_;
    
    my $sth=$self->dbh->prepare("UPDATE ".$self->fields." SET 
    label_id = ?, name = ?,type = ?, top = ?, `left` = ?,`right` = ?,`bottom` = ?,fontsize = ?, fontfamily = ?, fontweight = ?, whitespace = ?, height = ?
    WHERE id = ?;");
    return $sth->execute(@params);
    
}

sub deleteFieldData {
    my ($self, $id) = @_;

    my $sth = $self->dbh->prepare("DELETE FROM ".$self->fields." WHERE id = ?;");
    return $sth->execute($id);

}

sub getPrintQueue {
    my ($self, $borrowernumber, $printed) = @_;

    my $sth = $self->dbh->prepare("SELECT * FROM ".$self->printQueue." where borrowernumber = ? and printed = ?;");
    $sth->execute($borrowernumber, $printed);
    return $sth->fetchall_arrayref({});
}

sub setPrintQueue {
    my ($self, @params) = @_;

    my $sth=$self->dbh->prepare("INSERT INTO ".$self->printQueue." (borrowernumber,itemnumber, printed) VALUES (?,?,?)");
    return $sth->execute(@params);
}

sub deletePrintQueueData {
    my ($self, $id) = @_;

    my $sth = $self->dbh->prepare("DELETE FROM ".$self->printQueue." WHERE id = ?;");
    return $sth->execute($id);

}

sub updatePrintQueue {
    my ($self, @params) = @_;

    my $sth=$self->dbh->prepare("UPDATE ".$self->printQueue." SET borrowernumber = ?, itemnumber = ?, printed = ? WHERE id = ?");
    return $sth->execute(@params);
}


1;