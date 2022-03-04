package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Controllers::LabelController;

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

use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels;

=head1 API

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    try {
        my $labels = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels->new();
        my $response = $labels->listLabels();
        return $c->render(status => 200, openapi => $response);
    } catch {
        my $error = $_;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

sub set {
    my $c = shift->openapi->valid_input or return;

    my $req  = $c->req->json;
    try {
        my $labels = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels->new();
        $labels->setLabel($req);
        return $c->render(status => 201, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        return $c->render(status => 500, openapi => {message => $error->message});
    }
}

1;