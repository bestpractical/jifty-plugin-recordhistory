#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 3;

my $book = TestApp::Plugin::RecordHistory::Model::Book->new;
$book->create(
    title  => '1984',
    author => 'George Orwell',
);
ok($book->id, 'created a book');

is($book->changes->count, 1);

$book->start_change;
$book->end_change;

is($book->changes->count, 1, 'a change with no updates should not create a Change');

