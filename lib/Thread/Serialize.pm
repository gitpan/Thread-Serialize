package Thread::Serialize;

# Make sure we have version info for this module
# Make sure we do everything by the book from now on

$VERSION = '0.06';
use strict;

# Make sure we only load things that we need when we need it

use load;

# Make sure we can freeze and thaw

use Storable ();

# Execute external perl to obtain Storable signature (saves memory here)

open( my $handle,
 qq($^X -MStorable -e "print unpack('l',Storable::freeze( [] ))" | )
) or die "Cannot determine Storable signature\n";
our $iced = <$handle>;
undef( $handle );

# Satisfy -require-

1;

# The following subroutines are loaded on demand only

__END__

#---------------------------------------------------------------------------
#  IN: 1..N parameters to freeze
# OUT: 1 frozen scalar

sub freeze {

# If we have at least one element in the list
#  For all of the elements
#   Return truly frozen version if something special
#  Return the values contatenated with null bytes
# Else (empty list)
#  Return undef value

    if (@_) {
        foreach (@_) {
            return Storable::freeze( \@_ ) if !defined() or ref() or m#\0#;
        }
        return join( "\0",@_ );
    } else {
        return;
    }
} #freeze

#---------------------------------------------------------------------------
#  IN: 1 frozen scalar to defrost
# OUT: 1..N thawed data structure

sub thaw {

# Return now if nothing to return or not interested in result

    return unless defined( $_[0] ) and defined( wantarray );

# If we're interested in a list
#  Return thawed list from frozen info if frozen
#  Return list split from a normal string
# Elseif we have frozen stuff (and we want a scalar)
#  Thaw the list and return the first element
# Else (not frozen and we want a scalar)
#  Look for the first nullbyte and return string until then if found
#  Return the string

    if (wantarray) {
        return @{Storable::thaw( $_[0] )} if (unpack( 'l',$_[0] )||0) == $iced;
        split( "\0",$_[0] )
    } elsif ((unpack( 'l',$_[0] )||0) == $iced) {
        Storable::thaw( $_[0] )->[0];
    } else {
	return $1 if $_[0] =~ m#^([^\0]*)#;
        $_[0];
    }
} #thaw

#---------------------------------------------------------------------------

# standard Perl features

#---------------------------------------------------------------------------

sub import {

# Lose the class
# Obtain the namespace
# Obtain the names of the subroutines to export
# Allow for dirty tricks
# Export all subroutines specified

    shift;
    my $namespace = caller().'::';
    @_ = qw(freeze thaw) unless @_;
    no strict 'refs';
    *{$namespace.$_} = \&$_ foreach @_;
} #import

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Serialize - serialize data-structures between threads

=head1 SYNOPSIS

  use Thread::Serialize;    # export freeze() and thaw()

  use Thread::Serialize (); # must call fully qualified subs

  my $frozen = freeze( any data structure );
  any data structure = thaw( $frozen );

=head1 DESCRIPTION

                  *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0 and later.
 And then only when threads are enabled with -Dusethreads.  It
 is of no use with any version of Perl before 5.8.0 or without
 threads enabled.

                  *************************

The Thread::Serialize module is a library for centralizing the routines
used to serialize data-structures between threads.  Because of this central
location, other modules such as L<Thread::Conveyor>, L<Thread::Pool> or
L<Thread::Tie> can benefit from the same optimilizations that may take
place here in the future.

=head1 SUBROUTINES

There are only two subroutines.

=head2 freeze

 my $frozen = freeze( $scalar );

 my $frozen = freeze( @array );

The "freeze" subroutine takes all the parameters passed to it, freezes them
and returns a frozen representation of what was given.  The parameters can
be scalar values or references to arrays or hashes.  Use the L<thaw>
subroutine to obtain the original data-structure back.

=head2 thaw

 my $scalar = thaw( $frozen );

 my @array = thaw( $frozen );

The "thaw" subroutine returns the data-structure that was frozen with a call
to L<freeze>.  If called in a scalar context, only the first element of the
data-structure that was passed, will be returned.  Otherwise the entire
data-structure will be returned.

It is up to the developer to make sure that single argument calls to L<freeze>
are always matched by scalar context calls to L<thaw>.

=head1 OPTIMIZATIONS

To reduce memory and CPU usage, this module uses L<AutoLoader>.  This causes
subroutines only to be compiled in a thread when they are actually needed at
the expense of more CPU when they need to be compiled.  Simple benchmarks
however revealed that the overhead of the compiling single routines is not
much more (and sometimes a lot less) than the overhead of cloning a Perl
interpreter with a lot of subroutines pre-loaded.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2002-2003 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<Thread::Conveyor>, L<Thread::Pool>, L<Thread::Tie>.

=cut
