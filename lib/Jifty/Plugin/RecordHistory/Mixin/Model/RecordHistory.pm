package Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(transactions);

sub import {
    my $class = shift;
    my $caller = caller;

    $class->export_to_level(1, @_);

    $caller->add_trigger(after_set => sub {
        my $record = shift;
        my %args   = (
            column => undef,
            value  => undef,
            @_,
        );

        # add to the current transaction
    });
}

sub transactions {
    my $self = shift;
    my $transactions = Jifty::Plugin::RecordHistory::Model::TransactionCollection->new;
    $transactions->limit(
        column => 'record_class',
        value  => ref($self),
    );

    $transactions->limit(
        column => 'record_id',
        value  => $self->id,
    );

    return $transactions;
}

1;

