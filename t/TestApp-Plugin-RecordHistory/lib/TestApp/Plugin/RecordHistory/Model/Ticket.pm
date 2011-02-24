use strict;
use warnings;

package TestApp::Plugin::RecordHistory::Model::Ticket;
use Jifty::DBI::Schema;

use TestApp::Plugin::RecordHistory::Record schema {
    column subject =>
        type is 'varchar';
    column readable =>
        type is 'integer',
        default is 1;
    column updatable =>
        type is 'integer',
        default is 1;
    column deletable =>
        type is 'integer',
        default is 1;
};

use Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;

sub current_user_can {
    my $self  = shift;
    my $right = shift;

    return 1 if $right eq 'create';
    return 1 if $right eq 'read'   && $self->__value('readable');
    return 1 if $right eq 'update' && $self->__value('updatable');
    return 1 if $right eq 'delete' && $self->__value('deletable');

    return $self->SUPER::current_user_can($right, @_);
}

1;

