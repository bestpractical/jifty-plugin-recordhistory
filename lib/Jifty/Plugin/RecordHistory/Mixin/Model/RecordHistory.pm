package Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(
    changes
    start_change end_change current_change
    hide_change_field
);

sub import {
    my $class = shift;
    my %args  = @_;

    my $caller = caller;

    $class->export_to_level(1);

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
            column    => undef,
            value     => undef,
            old_value => undef,
            %{ shift @_ },
        );

        my $change = $self->current_change || do {
            my $change = Jifty::Plugin::RecordHistory::Model::Change->new;
            $change->create(
                record_class => ref($self),
                record_id    => $self->id,
                type         => 'update',
            );
            $change
        };

        # TODO: capture old_value somehow
        $change->add_change_field(
            field     => $args{column},
            old_value => $args{old_value},
            new_value => $args{value},
        );
    });

    # we hook into before_delete so we can still access ->changes etc
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

    # wrap update actions in a change so we can group them as one change with
    # many field changes
    $caller->add_trigger(start_update_action => sub {
        my $self = shift;
        $self->start_change;
    });

    $caller->add_trigger(end_update_action => sub {
        my $self = shift;
        $self->end_change;
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

sub start_change {
    my $self = shift;
    my $type = shift || 'update';

    my %args = (
        record_class => ref($self),
        record_id    => $self->id,
        type         => $type,
        @_,
    );

    my $change = Jifty::Plugin::RecordHistory::Model::Change->new;
    if ($type eq 'update') {
        $change->deferred_create(%args);
    }
    else {
        $change->create(%args);
    }

    return $self->{change} = $change;
}

sub end_change {
    my $self = shift;
    return delete $self->{change};
}

sub current_change {
    my $self = shift;
    return $self->{change};
}

sub hide_change_field {
    return 0;
}

1;

