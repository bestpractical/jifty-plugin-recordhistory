#!/usr/bin/env perl
use warnings;
use strict;

use Jifty::Test::Dist tests => 20;
my $server = Jifty::Test->make_server;
isa_ok($server, 'Jifty::TestServer');
my $URL  = $server->started_ok;
my $mech = Jifty::Test::WWW::Mechanize->new;

my $book = TestApp::Plugin::RecordHistory::Model::Book->new;
$book->create(
    title => '1984',
);
ok($book->id, 'created a book');

$book->start_change;
$book->set_title('Brave New World');
$book->set_author('Aldous Huxley');
$book->end_change;

$mech->get_ok($URL . '/book/history?id=' . $book->id);

