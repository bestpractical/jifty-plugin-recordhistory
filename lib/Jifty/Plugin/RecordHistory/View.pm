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

template 'no-changes' => sub {
    p {
        { class is 'no-changes' };
        _("No changes.")
    };
};

template 'changes' => sub {
    my $self    = shift;
    my $record  = get 'record';
    my $changes = $record->changes;

    if ($changes->count == 0) {
        show 'no-changes';
        return;
    }

    dl {
        { class is 'changes' };

        my $prev_date = '';
        while (my $change = $changes->next) {
            my $date = $change->created_on->ymd;
            if ($date ne $prev_date) {
                dt {
                    { class is 'date' };
                    $date
                };
                $prev_date = $date;
            }

            show 'change' => $change;
        }
    };
};

template 'change' => sub {
    my $self   = shift;
    my $change = shift;

    my $template = 'change-' . $change->type;

    dd {
        { class is 'change change-' . $change->type };
        div {
            { class is 'time' };
            $change->created_on->hms
        };
        show $template => $change
    };
};

template 'change-create' => sub {
    my $self   = shift;
    my $change = shift;

    span {
        outs _('Record created by ');
        show 'actor' => $change->created_by;
    };
};

template 'change-update' => sub {
    my $self   = shift;
    my $change = shift;

    my $change_fields = $change->change_fields;
    return if !$change_fields->count;

    span {
        outs _('Record updated by ');
        show 'actor' => $change->created_by;
    };

    ul {
        { class is 'change-fields' };
        while (my $change_field = $change_fields->next) {
            next if $change_field->record->hide_change_field($change_field);
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

    li {
        { class is 'change-field' };
        _("%1 changed from '%2' to '%3'", $field, $old, $new);
    };
};

template 'actor' => sub {
    my $self  = shift;
    my $actor = shift;

    return outs $actor if !ref($actor);

    return outs _('somebody') if !$actor->id || !$actor->current_user_can('read');
    return outs $actor->email if $actor->can('email');
    return outs _('user #%1', $actor->id);
};

1;

