#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 40;

my $user = TestApp::Plugin::RecordHistory::Model::User->new;
$user->create(
    name => 'tester',
);
ok($user->id, 'created user');

my $current_user = TestApp::Plugin::RecordHistory::CurrentUser->new(id => $user->id);

my $ticket = TestApp::Plugin::RecordHistory::Model::Ticket->new(current_user => $current_user);
$ticket->create(
    subject => 'Hello world',
);
ok($ticket->id, 'created a ticket');

isa_ok($ticket->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($ticket->changes->count, 1, 'one change');
my $change = $ticket->changes->first;
is($change->record_id, $ticket->id, 'record id');
is($change->record_class, 'TestApp::Plugin::RecordHistory::Model::Ticket', 'record class');
is($change->type, 'create', 'change has type create');
is($change->record->subject, 'Hello world', 'change->record');
is($change->created_by->id, $user->id, 'correct creator');

is($change->current_user->id, $user->id, 'current user is the user not superuser');
ok(!$change->current_user->is_superuser, 'not superuser');

$ticket->set_subject('Konnichiwa sekai');

isa_ok($ticket->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($ticket->changes->count, 2, 'two changes');
is($ticket->changes->first->type, 'create', 'first change is the create');
$change = $ticket->changes->last;
is($change->type, 'update', 'second change is the update');
is($change->change_fields->count, 1, 'one field updated');
is($change->created_by->id, $user->id, 'correct creator');

is($change->current_user->id, $user->id, 'current user is the user not superuser');
ok(!$change->current_user->is_superuser, 'not superuser');

my $change_field = $change->change_fields->first;
is($change_field->change->id, $change->id, 'associated with the right change');
is($change_field->field, 'subject');
is($change_field->new_value, 'Konnichiwa sekai');
is($change_field->old_value, 'Hello world');

is($change_field->current_user->id, $user->id, 'current user is the user not superuser');
ok(!$change_field->current_user->is_superuser, 'not superuser');

$ticket->set_updatable(0);

isa_ok($ticket->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($ticket->changes->count, 3, 'three changes');
$change = $ticket->changes->last;
is($change->type, 'update', 'last change is the update');
is($change->change_fields->count, 1, 'one field updated');
is($change->created_by->id, $user->id, 'correct creator');

is($change->current_user->id, $user->id, 'current user is the user not superuser');
ok(!$change->current_user->is_superuser, 'not superuser');

my $change_field = $change->change_fields->first;
is($change_field->change->id, $change->id, 'associated with the right change');
is($change_field->field, 'updatable');
is($change_field->new_value, 0);
is($change_field->old_value, 1);

is($change_field->current_user->id, $user->id, 'current user is the user not superuser');
ok(!$change_field->current_user->is_superuser, 'not superuser');

# make sure we don't create spurious changes when a record couldn't be updated
$ticket->set_updatable(1);
is($ticket->updatable, 0, "ticket was not updated");
is($ticket->changes->count, 3, "still only three changes since we couldn't update the record");

