package Jifty::Plugin::RecordHistory::View;
use strict;
use warnings;
use Jifty::View::Declare -base;

sub mount_view {
    my ($class, $model, $vclass, $path) = @_;
    my $caller = caller(0);

    # Sanitize the arguments
    $model = ucfirst($model);
    $vclass ||= $caller.'::'.$model;
    $path ||= '/'.lc($model);

    # Load the view class, alias it, and define its object_type method
    Jifty::Util->require($vclass);
    eval qq{package $caller;
            alias $vclass under '$path'; 1} or die $@;

    # Override object_type
    no strict 'refs';
    my $object_type = $vclass."::object_type";

    # Avoid the override if object_type() is already defined
    *{$object_type} = sub { $model } unless defined *{$object_type};
}

sub object_type {
    my $self = shift;
    my $object_type = $self->package_variable('object_type') || get('object_type');

    warn "No object type found for $self"
        if !$object_type;

    return $object_type;
}

sub page_title {
    my $self = shift;
    return _('History for %1', $self->object_type);
}

sub record_class {
    my $self = shift;

    # If object_type is set via set, don't cache
    if (!$self->package_variable('object_type') && get('object_type')) {
        return Jifty->app_class('Model', $self->object_type);
    }

    # Otherwise, assume object_type is permanent
    else {
        return ($self->package_variable('record_class')
            or ($self->package_variable( record_class =>
                    Jifty->app_class('Model', $self->object_type))));
    }
}

sub load_record {
    my $self = shift;

    my $id = get('id');

    my $record = $self->record_class->new;
    $record->load($id);
    return $record;
}

template 'index.html' => page { title => shift->page_title } content {
    show './list';
};

template 'header' => sub {
};

template 'footer' => sub {
};

template 'list' => sub {
    my $self = shift;
    set record => $self->load_record;
    show 'header';
    show 'changes';
    show 'footer';
};

template 'changes' => sub {
    my $self    = shift;
    my $record  = get 'record';
    my $changes = $record->changes;

    while (my $change = $changes->next) {
        show 'change' => $change;
    }
};

template 'change' => sub {
    my $self   = shift;
    my $change = shift;

    my $template = 'change-' . $change->type;

    show $template => $change;
};

template 'change-create' => sub {
    my $self   = shift;
    my $change = shift;
};

template 'change-update' => sub {
    my $self   = shift;
    my $change = shift;

    my $change_fields = $change->change_fields;
    return if !$change_fields->count;

    ul {
        while (my $change_field = $change_fields->next) {
            show 'change_field' => $change_field;
        }
    };
};

template 'change_field' => sub {
    my $self         = shift;
    my $change_field = shift;

    my $field = $change_field->field;
    my $old   = $change_field->old_value;
    my $new   = $change_field->new_value;

    li { _("%1 changed from '%2' to '%3'.", $field, $old, $new) };
};

1;

