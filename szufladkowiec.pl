#!/usr/bin/perl -w
#use strict;
#use LWP::Simple;

#bierze liste i sciaga z pdb
if ($#ARGV != 0) {die "Program uzywany z parametrami!\
	[lista plikow PDB]\n";}

open(INPUT1, "< $ARGV[0]") or die "Can not open an input file: $!";
my @lista1=<INPUT1>;
close (INPUT1);
chomp @lista1;

foreach $nazwa(@lista1){
$nazwa=~tr/A-Z/a-z/;
	if($nazwa=~/^pdb/){
	$kod=$nazwa.".ent.Z";
	print "downloading $kod\n";
	}
	else{
	$kod="pdb".$nazwa.".ent.Z";
	print "downloading $kod\n";
	}

#sciagaj z PDB
$link="ftp://ftp.rcsb.org/pub/pdb/data/structures/all/pdb/".$kod;
`wget $link`;

}
