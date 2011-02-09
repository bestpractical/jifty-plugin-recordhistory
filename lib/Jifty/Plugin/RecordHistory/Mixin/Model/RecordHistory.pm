package Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(changes);

sub import {
    my $class = shift;
    my $caller = caller;

    $class->export_to_level(1, @_);

    $caller->add_trigger(after_create => sub {
        my $self = shift;
        my $id   = ${ shift @_ };

        my $change = Jifty::Plugin::RecordHistory::Model::Change->new;
        $change->create(
            record_class => ref($self),
            record_id    => $id,
            type         => 'create',
        );
    });

    $caller->add_trigger(after_set => sub {
        my $record = shift;
        my %args   = (
            column => undef,
            value  => undef,
            @_,
        );

        # add to the current change
    });
}

sub changes {
    my $self = shift;
    my $changes = Jifty::Plugin::RecordHistory::Model::ChangeCollection->new;
    $changes->limit(
        column => 'record_class',
        value  => ref($self),
    );

    $changes->limit(
        column => 'record_id',
        value  => $self->id,
    );

    return $changes;
}

1;

