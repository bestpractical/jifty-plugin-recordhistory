package Jifty::Plugin::RecordHistory::Model::Transaction;
use warnings;
use strict;

use Jifty::DBI::Schema;
use Jifty::Record schema {
    column record_id =>
        type is 'integer',
        is mandatory;
};

sub record {
    my $self = shift;
    my $record = $self->record_class;
    $record->load($self->record_id);
    return $record;
}

1;

