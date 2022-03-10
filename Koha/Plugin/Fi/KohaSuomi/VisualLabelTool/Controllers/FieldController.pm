package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Controllers::FieldController;

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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';
use Try::Tiny;

use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields;

=head1 API

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    try {
        my $fields = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields->new();
        my $response = $fields->listFields();
        return $c->render(status => 200, openapi => $response);
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $id = $c->validation->param('field_id');

    try {
        my $fields = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Fields->new();
        $fields->deleteField($id);
        return $c->render(status => 200, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 500, openapi => {message => "Something went wrong, check the logs"});
    }
}

1;