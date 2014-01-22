#!/usr/bin/perl -w
use warnings;
use strict;

if($#ARGV >-1){
  if (($ARGV[0] eq "-getfaa") and ($#ARGV != 2)) {die "Program require arguments! [-getfaa] [list] [dir]\n";}
  elsif(($ARGV[0] eq "-psiblast") and  ($#ARGV != 4)) {die "Program require arguments! [-psiblast] [list] [dir] [outdir] [db path]\n";}
}
else  {die "Program require arguments! [-getfaa | -psiblast ] \n";}

my ($fasta);

#check if for given ID fasta file exists
if($ARGV[0] eq "-getfaa"){
  mkdir "$ARGV[2]" if (!-d $ARGV[2]);
  chdir "$ARGV[2]" if (-d $ARGV[2]);
  if(-e "$ARGV[1]"){
    $fasta=$ARGV[1];
  }
  elsif(-e $ARGV[1].".fasta"){
    $fasta=$ARGV[1].".fasta";
  }
  else{
    get_fasta($ARGV[1]);
    $fasta=$ARGV[1].".fasta";
  }
  chdir "../";
}

#create profile
if($ARGV[0] eq "-psiblast"){
  my $profile=substr($ARGV[1],0,rindex($ARGV[1],".")).".chk";
  my $output=substr($ARGV[1],0,rindex($ARGV[1],".")).".out";
  my $outdir=$ARGV[3];
  my $db=$ARGV[4];
  mkdir "$outdir" if (!-d $outdir);
  make_profile($fasta,$ARGV[2],$profile,$output,$outdir,$db);
}


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



