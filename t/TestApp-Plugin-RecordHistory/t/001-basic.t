#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 9;

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
is($change->record->title, '1984', 'change->record');

isa_ok($change->change_fields, 'Jifty::Plugin::RecordHistory::Model::ChangeFieldCollection', 'change field collection');
is($change->change_fields->count, 0, 'generate no ChangeFields for create');

$book->set_title('Nineteen Eighty-Four');

isa_ok($book->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($book->changes->count, 2, 'two changes');
is($book->changes->first->type, 'create', 'first change is the create');
$change = $book->changes->last;
is($change->type, 'update', 'second change is the update');
is($change->change_fields->count, 1, 'one field updated');

my $change_field = $change->change_fields->first;
is($change_field->change->id, $change->id, 'associated with the right change');
is($change_field->field, 'title');
is($change_field->new_value, 'Nineteen Eighty-Four');
is($change_field->old_value, '1984');

