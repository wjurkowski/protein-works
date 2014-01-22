#!/usr/bin/perl -w
use warnings;
use strict;
use lib '.';

if ($#ARGV != 0) {die "Program require arguments! [fasta_file|UniprotID] \n";}
my ($fasta);

if(-e $ARGV[0]){
  $fasta=$ARGV[0];
}
else{
  get_fasta($ARGV[0]);
  $fasta=$ARGV[0].".fasta";
}

make_profile($ARGV[0]);

sub get_fasta{
  my $file=shift;
  my $string="http://www.uniprot.org/uniprot/".$file.".fasta";
  `wget $string`;
}

sub make_profile{
  my $file=shift;
  `blastpgp -j 2 -m 6 -F F -e 1.e-5 -i $fasta -d nr -C $file.".chk" >psiblast.out`
}



