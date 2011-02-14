package Jifty::Plugin::RecordHistory;
use strict;
use warnings;
use base qw/Jifty::Plugin/;

our $VERSION = '0.01';

sub init {
    Jifty->web->add_css('record-history.css');
}

1;

__END__

=head1 NAME

Jifty::Plugin::RecordHistory - track all changes made to a record class

=head1 SYNOPSIS

Add the following to your config:

    framework:
        Plugins:
            - RecordHistory: {}

Add the following to one or more record classes:

    use Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory;

=head1 DESCRIPTION

When you use L<Jifty::Plugin::RecordHistory::Mixin::Model::RecordHistory> in a
record class, we add a C<changes> method which returns an
L<Jifty::Plugin::RecordHistory::Model::ChangeCollection>. These changes describe
the updates made to the record, including its creation. Some changes also have
C<change_fields> which describe updates to the individual fields of the record.

You do not need to do anything beyond adding C<RecordHistory> to your plugins
and using the mixin to your record class(es) to enjoy transaction history. The
mixin even hooks into Jifty itself to observe record creation, updates, and
deletions.

=head2 Grouping

By default, the only mechanism that groups together change_fields onto a single
change object is L<Jifty::Action::Record::Update> (and its subclasses that do
not override C<take_action>). But if you want to make a number of field updates
that need to be grouped into a single logical change, you can call
C<start_change> and C<end_change> yourself on the record object.

=head2 Views

If you want to display changes for a record class, mount the following into
your view tree to expose a default view at C</foo/history?id=42> (or you can of
course set C<id> via dispatcher rule).

    use Jifty::Plugin::RecordHistory::View;
    alias Jifty::Plugin::RecordHistory::View under '/foo/history', {
        object_type => 'Foo',
    };

Alternatively, if you want to extend the default templates, you can subclass
L<Jifty::Plugin::RecordHistory::View> in the same way as
L<Jifty::View::Declare::CRUD>.

=head1 SEE ALSO

L<Jifty::Plugin::ActorMetadata>

=head1 AUTHOR

Shawn M Moore C<< <sartak@bestpractical.com> >>

=head1 LICENSE

Jifty::Plugin::RecordHistory is Copyright 2011 Best Practical Solutions, LLC.
Jifty::Plugin::RecordHistory is distributed under the same terms as Perl itself.

=cut

