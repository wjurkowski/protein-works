#!/usr/bin/perl -w
use warnings;
use strict;

if ($#ARGV < 3) {die "Program require arguments! [fasta_file|UniprotID] [directory] [outdir] [db path]\n";}
my ($fasta);

#check if for given ID fasta file exists
mkdir "$ARGV[1]" if (!-d $ARGV[1]);
chdir "$ARGV[1]" if (-d $ARGV[1]);
if(-e "$ARGV[0]"){
  $fasta=$ARGV[0];
}
elsif(-e $ARGV[0].".fasta"){
  $fasta=$ARGV[0].".fasta";
}
else{
  get_fasta($ARGV[0]);
  $fasta=$ARGV[0].".fasta";
}
chdir "../";

#create profile
my $profile=substr($ARGV[0],0,rindex($ARGV[0],".")).".chk";
my $output=substr($ARGV[0],0,rindex($ARGV[0],".")).".out";
my $outdir=$ARGV[2];
my $db=$ARGV[3];
mkdir "$outdir" if (!-d $outdir);
make_profile($fasta,$ARGV[1],$profile,$output,$outdir,$db);

#functions
#download fasta from UniProt
sub get_fasta{
  my $file=shift;
  my $string="http://www.uniprot.org/uniprot/".$file.".fasta";
  `wget $string`;
}

#run psiblast and save profiles for each fasta sequence
sub make_profile{
  my $fasta=shift;
  my $dir=shift;
  my $profile=shift;
  my $output=shift;
  my $outputdir=shift;
  my $db=shift;
  print "blastpgp -j 2 -m 6 -F F -e 1.e-5 -i $dir/$fasta -d $db/nr -C $outputdir/$profile > $outputdir/$output\n";
  `blastpgp -j 2 -m 6 -F F -e 1.e-5 -i $dir/$fasta -d $db/nr -C $outputdir/$profile > $outputdir/$output`
}



