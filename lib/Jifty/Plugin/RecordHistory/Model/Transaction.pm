package Jifty::Plugin::RecordHistory::Model::Transaction;
use warnings;
use strict;

use Jifty::DBI::Schema;
use Jifty::Record schema {
    column record_class =>
        type is 'varchar',
        is mandatory,
        is immutable;

    column record_id =>
        type is 'integer',
        is mandatory,
        is immutable;

    # XXX: associate this with the app's user modl
    column created_by =>
        type is 'integer',
        label is 'Created by',
        is immutable;

    column created_on =>
        type is 'timestamp',
        label is 'Created on',
        filters are qw(Jifty::Filter::DateTime Jifty::DBI::Filter::DateTime),
        is immutable;

    column type =>
        type is 'text',
        label is 'Type',
        is immutable;

    column changes =>
        refers_to Jifty::Plugin::RecordHistory::Model::TransactionEntryCollection by 'transaction';
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

