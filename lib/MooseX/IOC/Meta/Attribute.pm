
package MooseX::IOC::Meta::Attribute;
use Moose;

use IOC::Registry;

our $VERSION = '0.01';

extends 'Moose::Meta::Attribute';

# this never changes, so we can 
# just store it once - SL
my $REGISTRY = IOC::Registry->new;

around '_process_options' => sub {
    my $next = shift;
    my ($self, $name, $options) = @_;
    if (exists $options->{service}) {
        (!exists $options->{default})
            || confess "You cannot assign a 'default' and a 'service' in the same attribute";
        
        my $service = $self->_process_service($options->{service});
        
        $options->{default} = sub { 
            $REGISTRY->locateService(@{$service->(@_)}) 
        };
    }
    $next->($self, $name, $options);
};

sub _process_service {
    my ($self, $service) = @_;
    return $service 
        if ref $service eq 'CODE';
    # otherwise ...
    $service = [ $service ] if ref $service ne 'ARRAY';    
    return sub { $service };
}

# register this as a metaclass alias ...
package Moose::Meta::Attribute::Custom::IOC;
sub register_implementation { 'MooseX::IOC::Meta::Attribute' }

1;

__END__

=pod

=head1 NAME

MooseX::IOC::Meta::Attribute

=head1 DESCRIPTION

No real user serviceable parts in here ... see L<MooseX::IOC> docs. 

=head1 METHODS

=over 4

=item B<meta>

This returns the role meta object.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
