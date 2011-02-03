package Jifty::Plugin::RecordHistory::Model::TransactionEntry;
use warnings;
use strict;

use Jifty::DBI::Schema;
use Jifty::Record schema {
    column transaction =>
        refers to Jifty::Plugin::RecordHistory::Model::Transaction,
        is immutable;
};

sub record {
    my $self = shift;
    return $self->transaction->record;
}

sub delegate_current_user_can {
    my $self  = shift;
    $self->transaction->delegate_current_user_can(@_);
}

1;


