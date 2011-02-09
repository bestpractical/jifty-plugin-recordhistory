#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 2;

my $book = TestApp::Plugin::RecordHistory::Model::Book->new;
$book->create(
    title => '1984',
);
ok($book->id, 'created a book');

isa_ok($book->changes, 'Jifty::Plugin::RecordHistory::Model::ChangeCollection');

