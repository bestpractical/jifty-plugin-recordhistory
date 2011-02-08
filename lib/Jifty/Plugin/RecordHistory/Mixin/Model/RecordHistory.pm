package Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;
use strict;
use warnings;

sub import {
    my $class = shift;
    my $caller = caller;

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

