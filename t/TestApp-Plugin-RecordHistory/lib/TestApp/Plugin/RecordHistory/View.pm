package TestApp::Plugin::RecordHistory::View;
use Jifty::View::Declare -base;

alias Jifty::Plugin::RecordHistory::View under '/book/history', {
    object_type => 'Book',
};

1;

