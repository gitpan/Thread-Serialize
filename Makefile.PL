require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Serialize",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'serialize data-structures between threads',
 VERSION_FROM	=> 'lib/Thread/Serialize.pm',
 PREREQ_PM	=> {
		   load => '0.09',
		   Storable => 0,
                   },
);
