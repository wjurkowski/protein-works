#!/usr/bin/perl -w

use strict;
use warnings;

if ($#ARGV != 0) {die "Program used with parameters [mol2 file]\n";}

my @library=open_file($ARGV[0]);

for(my $i=0;$i<$#library;$i++){
	my $line=$library[$i];
	if($line =~ "<TRIPOS>SUBSTRUCTURE"){
		my @x=split(/\s+/,$library[$i+1]);
		$x[1] =~s/M_//; 
		my $name= $x[1];
		my @tab=split(/\s+/,$library[$i+4]);
		splice(@tab,0,2);
		unshift(@tab,$name);
	        print "$tab[0]";
		for (my $k=1;$k<$#tab;$k++){
	        	print ",$tab[$k]";
		}
		print "\n";
		$i=$i+5;
	}
}
		

# open a file with the file name as input
sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}

