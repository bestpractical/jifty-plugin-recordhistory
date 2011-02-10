#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 7;

my $book = TestApp::Plugin::RecordHistory::Model::Book->new;
$book->create(
    title => '1984',
);
ok($book->id, 'created a book');

Jifty->web->request(Jifty::Request->new);
Jifty->web->response(Jifty::Response->new);

my $action = TestApp::Plugin::RecordHistory::Action::UpdateBook->new(
    record    => $book,
    arguments => {
        title  => 'Brave New World',
        author => 'Aldous Huxley',
    },
);

$action->run;

ok($action->result->success);

isa_ok($book->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');
is($book->changes->count, 2, 'two changes');
is($book->changes->first->type, 'create', 'first change is the create');
my $change = $book->changes->last;
is($change->type, 'update', 'second change is the update');
is($change->change_fields->count, 2, 'two fields updated');

