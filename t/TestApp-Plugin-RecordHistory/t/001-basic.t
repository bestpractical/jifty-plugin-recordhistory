#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 8;

my $book = TestApp::Plugin::RecordHistory::Model::Book->new;
$book->create(
    title => '1984',
);
ok($book->id, 'created a book');

isa_ok($book->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($book->changes->count, 1, 'one change');
my $change = $book->changes->first;
is($change->record_id, $book->id, 'record id');
is($change->record_class, 'TestApp::Plugin::RecordHistory::Model::Book', 'record class');
is($change->type, 'create', 'change has type create');

isa_ok($change->change_fields, 'Jifty::Plugin::RecordHistory::Model::ChangeFieldCollection', 'change field collection');
is($change->change_fields->count, 0, 'generate no ChangeFields for create');

