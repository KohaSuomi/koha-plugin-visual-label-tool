package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Controllers::ItemController;

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
use Koha::Items;
use Koha::DateUtils qw( dt_from_string output_pref );

use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print;

=head1 API

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $type = $c->validation->param('type');
    my $today_dt = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1});
    my $items;
    my $user = $c->stash('koha.user');
    try {
        if ($type eq 'received') {
            $items = Koha::Items->search({dateaccessioned => $today_dt})->unblessed;
        } else {
            my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
            $items = $print->getPrintQueue($user->borrowernumber);
        }
        return $c->render(status => 200, openapi => $items);
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

1;