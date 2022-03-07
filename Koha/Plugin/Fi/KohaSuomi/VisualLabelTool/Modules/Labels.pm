package Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Labels;

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
use Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database;
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

sub db {
    my ($self) = @_;
    return Koha::Plugin::Fi::KohaSuomi::VisualLabelTool::Modules::Database->new;
}

sub _validateData {
    my ($self, $params) = @_;
    my $error;

    $error = $self->_validateLabelParams($params);
    $error = $self->_validateFieldParams($params->{fields});

    if ($params->{signum}) {
        $error = $self->_validateFieldParams($params->{signum}->{fields});
    }

    return $error;

}

sub _validateLabelParams {
    my ($self, $params) = @_;

    unless ($params->{name}) {
        return "Missing name value";
    }
    unless ($params->{labelcount}) {
        return "Missing labelcount value";
    }
    unless ($params->{dimensions}->{width}) {
        return "Missing width value";
    }
    unless ($params->{dimensions}->{height}) {
        return "Missing height value";
    }
    unless ($params->{dimensions}->{paddingTop}) {
        return "Missing paddingTop value";
    }
    unless ($params->{dimensions}->{paddingBottom}) {
        return "Missing paddingBottom value";
    }
    unless ($params->{dimensions}->{paddingLeft}) {
        return "Missing paddingLeft value";
    }
    unless ($params->{dimensions}->{paddingRight}) {
        return "Missing paddingRight value";
    }
    if ($params->{signum}) {
        unless ($params->{signum}->{dimensions}->{width}) {
        return "Missing signum width value";
        }
        unless ($params->{signum}->{dimensions}->{height}) {
            return "Missing signum height value";
        }
        unless ($params->{signum}->{dimensions}->{paddingTop}) {
            return "Missing signum paddingTop value";
        }
        unless ($params->{signum}->{dimensions}->{paddingBottom}) {
            return "Missing signum paddingBottom value";
        }
        unless ($params->{signum}->{dimensions}->{paddingLeft}) {
            return "Missing signum paddingLeft value";
        }
        unless ($params->{signum}->{dimensions}->{paddingRight}) {
            return "Missing signum paddingRight value";
        }
    }
    return;
}

sub _validateFieldParams {
    my ($self, $fields) = @_;

    foreach my $field (@{$fields}) {
        unless ($field->{name}) {
            return "Missing name value";
        }
        unless ($field->{dimensions}->{top}) {
            return "Missing top value";
        }
        unless ($field->{dimensions}->{left}) {
            return "Missing left value";
        }
        unless ($field->{dimensions}->{fontSize}) {
            return "Missing fontSize value";
        }
    }
    return;
}

sub listLabels {
    my ($self) = @_;

    my $labels = $self->db->getLabelsData();
    my $wrapped;

    foreach my $label (@$labels) {
        my $wrap = $self->wrapLabel($label);
        my $fields = $self->db->getFieldData($label->{id});
        my ($labelFields, $signumFields) = $self->wrapFields($fields);
        $wrap->{fields} = $labelFields;
        $wrap->{signum}->{fields} = $signumFields if $wrap->{signum};
        push @$wrapped, $wrap;
    }
    return $wrapped;

}

sub getLabel {
    my ($self) = @_;
}

sub setLabel {
    my ($self, $params) = @_;
    
    my ($response, $error);
    $error = $self->_validateData($params);
    unless ($error) {
        my $label_id = $self->db->setLabelData($self->parseLabel($params));
        foreach my $field (@{$params->{fields}}) {
            $self->db->setFieldData($self->parseField($label_id, 'label', $field));
        };

        foreach my $field (@{$params->{signum}->{fields}}) {
            $self->db->setFieldData($self->parseField($label_id, 'signum', $field));
        };
    }
    return ($response, $error);
}

sub updateLabel {
    my ($self, $label_id, $params) = @_;
    
    my ($response, $error);
    $error = $self->_validateData($params);
    unless ($error) {
        my @data = $self->parseLabel($params);
        push @data, $label_id;
        $self->db->updateLabelData(@data);
        foreach my $field (@{$params->{fields}}) {
            my @fieldData = $self->parseField($label_id, 'label', $field);
            push @fieldData, $field->{id};
            $self->db->updateFieldData(@fieldData);
        };

        foreach my $field (@{$params->{signum}->{fields}}) {
            my @fieldData = $self->parseField($label_id, 'signum', $field);
            push @fieldData, $field->{id};
            $self->db->updateFieldData(@fieldData);
        };

    }
    return ($response, $error);
}

sub parseLabel {
    my ($self, $params) = @_;
    
    return (
        $params->{name},
        $params->{labelcount},
        $params->{dimensions}->{width},
        $params->{dimensions}->{height},
        $params->{dimensions}->{paddingTop},
        $params->{dimensions}->{paddingBottom},
        $params->{dimensions}->{paddingLeft},
        $params->{dimensions}->{paddingRight},
        $params->{signum}->{dimensions}->{width},
        $params->{signum}->{dimensions}->{height},
        $params->{signum}->{dimensions}->{paddingTop},
        $params->{signum}->{dimensions}->{paddingBottom},
        $params->{signum}->{dimensions}->{paddingLeft},
        $params->{signum}->{dimensions}->{paddingRight}
    );
}

sub parseField {
    my ($self, $label_id, $type, $field) = @_;
    
    return (
        $label_id,
        $field->{name},
        $type,
        $field->{dimensions}->{top},
        $field->{dimensions}->{left},
        $field->{dimensions}->{fontSize}
    );
}

sub wrapLabel {
    my ($self, $label) = @_;
    
    my $wrap = {
        id => $label->{id},
        name => $label->{name},
        labelcount => $label->{labelcount},
        dimensions => { 
            width => $label->{width},
            height => $label->{height},
            paddingTop => $label->{top},
            paddingBottom => $label->{bottom},
            paddingLeft => $label->{left},
            paddingRight => $label->{right}
        }
    };
    if ($label->{signum_width} && $label->{signum_height}) {
        $wrap->{signum} = {
            dimensions => {
                width => $label->{signum_width},
                height => $label->{signum_height},
                paddingTop => $label->{signum_top},
                paddingBottom => $label->{signum_bottom},
                paddingLeft => $label->{signum_left},
                paddingRight => $label->{signum_right}
            }
        }
    };
    return $wrap;
}

sub wrapFields {
    my ($self, $fields) = @_;

    my ($wrappedLabel, $wrappedSignum);

    foreach my $field (@$fields) {
        my $wrap = {
            id => $field->{id},
            name => $field->{name},
            dimensions => {
                top => $field->{top},
                left => $field->{left},
                fontSize => $field->{fontsize}
            }
        };
        if ($field->{type} eq "signum") {
            push @$wrappedSignum, $wrap;
        } else {
            push @$wrappedLabel, $wrap;
        }
    }

    return ($wrappedLabel, $wrappedSignum);
}

1;