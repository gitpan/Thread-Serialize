BEGIN {				# Magic Perl CORE pragma
    if ($ENV{PERL_CORE}) {
        chdir 't' if -d 't';
        @INC = '../lib';
    }
}

use Test::More tests => 8;

use Thread::Serialize; # can't fake bare import call yet with Test::More
use_ok( 'Thread::Serialize',			'load the library' );
can_ok( 'Thread::Serialize',qw(
 freeze
 thaw
) );

my $scalar = '1234';
my $frozen = freeze( $scalar );
is( thaw($frozen),$scalar,			'check contents' );

my @array = qw(a b c);
$frozen = freeze( @array );
is( join('',thaw($frozen)),join('',@array),	'check contents' );

$frozen = freeze( \@array );
is( join('',@{thaw($frozen)}),join('',@array),	'check contents' );

$frozen = freeze();
is( join('',thaw($frozen)),'',			'check contents' );

$frozen = freeze( undef );
ok( !defined( thaw($frozen) ),			'check contents' );

my %hash = (a => 'A', b => 'B', c => 'C');
$frozen = freeze( \%hash );
is( join('',%{thaw($frozen)}),join('',%hash),	'check contents' );
