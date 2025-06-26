package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Controllers::PrintController;

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
use Koha::Serial::Items;
use C4::Context;

=head1 API

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $label_id = $c->validation->param('label_id');
    my $test = $c->validation->param('test');
    my $req  = $c->req->json;
    try {
        my $print= Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
        my $response = $print->printLabel($label_id, $test, $req);
        $response = [] unless $response;
        return $c->render(status => 200, openapi => $response);
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

sub listItems {
    my $c = shift->openapi->valid_input or return;

    my $type = $c->validation->param('type');
    my $today_dt = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1});
    my $items;
    my $user = $c->stash('koha.user');
    my $userenv_branch = C4::Context->userenv->{'branch'};
    try {
        if ($type eq 'received') {
            $items = Koha::Items->search({dateaccessioned => $today_dt, notforloan => { '!=' => -1 }, homebranch => $userenv_branch})->unblessed;
        } elsif($type eq 'receivedserials') {
	    $items = Koha::Items->search({dateaccessioned => $today_dt, homebranch => $userenv_branch, itemnumber => { in => [Koha::Serial::Items->search->get_column('itemnumber')] } } )->unblessed;
        } elsif($type eq 'printed') {
            my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
            $items = $print->getPrintQueue($user->borrowernumber, 1);
        } else {
            my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
            $items = $print->getPrintQueue($user->borrowernumber, 0);
        }
        $items = [] unless $items;
        return $c->render(status => 200, openapi => $items);
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

sub setQueue {
    my $c = shift->openapi->valid_input or return;

    my $req  = $c->req->json;
    my $user = $c->stash('koha.user');
    $req->{borrowernumber} = $user->borrowernumber unless $req->{borrowernumber};
    try {
        my $print= Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
        my $response = $print->setPrintQueue($req);
        return $c->render(status => 200, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error});
    }
}

sub removeFromQueue {
    my $c = shift->openapi->valid_input or return;

    my $queue_id = $c->validation->param('queue_id');
    try {
        my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
        my $response = $print->deleteFromPrintQueue($queue_id);
        return $c->render(status => 200, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error});
    }
}

sub updateQueue {
    my $c = shift->openapi->valid_input or return;

    my $req  = $c->req->json;
    my $user = $c->stash('koha.user');
    $req->{borrowernumber} = $user->borrowernumber unless $req->{borrowernumber};
    try {
        my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
        if ($req->{queue_id}) {
            $print->updatePrintQueue($req);
        } else {
            $print->setPrintQueue($req);
        }
        return $c->render(status => 200, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error});
    }
}

sub cleanQueue {
    my $c = shift->openapi->valid_input or return;

    my $p = $c->validation->param('p');
    my $w = $c->validation->param('w');
    my $user = $c->stash('koha.user');
    try {
        my $print = Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Print->new();
        my $response = $print->cleanPrintQueue($user->borrowernumber, $p,  $w);
        return $c->render(status => 200, openapi => {message => "Success"});
    } catch {
        my $error = $_;
        warn Data::Dumper::Dumper $error;
        return $c->render(status => 400, openapi => {message => $error->message});
    }
}

1;
