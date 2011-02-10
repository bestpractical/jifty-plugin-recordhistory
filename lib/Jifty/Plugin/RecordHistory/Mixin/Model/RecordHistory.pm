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

        return if !$id; # the actual create failed

        my $change = Jifty::Plugin::RecordHistory::Model::Change->new;
        $change->create(
            record_class => ref($self),
            record_id    => $id,
            type         => 'create',
        );
    });

    $caller->add_trigger(after_set => sub {
        my $self = shift;
        my %args   = (
            column => undef,
            value  => undef,
            %{ shift @_ },
        );

        # TODO: instead of always creating a change, see if there's an active one
        my $change = Jifty::Plugin::RecordHistory::Model::Change->new;
        $change->create(
            record_class => ref($self),
            record_id    => $self->id,
            type         => 'update',
        );

        # TODO: capture old_value somehow
        $change->add_change_field(
            field     => $args{column},
            new_value => $args{value},
        );
    });

    # we hook into before_delete so we can still access changes etc
    $caller->add_trigger(before_delete => sub {
        my $self = shift;

        my $changes = $self->changes;
        while (my $change = $changes->next) {
            my $change_fields = $change->change_fields;
            while (my $change_field = $change_fields->next) {
                $change_field->delete;
            }

            $change->delete;
        }
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

    $changes->order_by(
        column => 'id',
        order  => 'asc',
    );

    return $changes;
}

1;

