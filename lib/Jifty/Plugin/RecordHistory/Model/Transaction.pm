package Jifty::Plugin::RecordHistory::Model::Transaction;
use warnings;
use strict;

use Jifty::DBI::Schema;
use Jifty::Record schema {
    column record_id =>
        type is 'integer',
        is mandatory,
        is immutable;
};

sub record {
    my $self = shift;
    my $record = $self->record_class;
    $record->load($self->record_id);
    return $record;
}

sub delegate_current_user_can {
    my $self  = shift;
    my $right = shift;
    my %args  = @_;

    $right = 'update' if $right ne 'read';

    return $self->record->current_user_can($right);
}

1;

