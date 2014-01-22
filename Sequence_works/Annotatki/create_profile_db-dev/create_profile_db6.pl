#!/usr/bin/perl -w
use warnings;
use strict;
use File::Copy;

if($#ARGV >-1){
  if (($ARGV[0] eq "-sf") and ($#ARGV != 1)) {die "Program require arguments! [-sf] [multi fasta] \n";}
  elsif (($ARGV[0] eq "-gf") and ($#ARGV != 2)) {die "Program require arguments! [-gf] [multi fasta] [Uniprot ID]\n";}
  elsif(($ARGV[0] eq "-psiblast") and  ($#ARGV != 4)) {die "Program require arguments! [-psiblast] [list] [dir] [outdir] [db path]\n";}
  elsif(($ARGV[0] eq "-chk2mtx") and  ($#ARGV != 2)) {die "Program require arguments! [-chk2mtx] [directory] [fasta db]\n";}
  #else  {die "$#ARGV Program require arguments! [-prep | -psiblast] \n";}
}
else  {die "Program require arguments! [-prep | -psiblast | -chk2mtx ] \n";}

if ($ARGV[0] eq "-sf"){
  split_fasta($ARGV[1]);
  #split_large_fasta($ARGV[1]);
}

if ($ARGV[0] eq "-gf"){
  grep_fasta($ARGV[1],$ARGV[2]);
}

if ($ARGV[0] eq "-psiblast"){
  my $lista=$ARGV[1];
  my @nazwy=open_file(\$lista);
  my $dir=$ARGV[2];
  my $db=$ARGV[4];
  my $range=100000;
  my $random=int(rand($range));
  my $outdir=$ARGV[3]."-".$random;
  mkdir "$outdir" if (!-d $outdir);
  foreach my $nazwa(@nazwy){
    my $profile=substr($nazwa,0,rindex($nazwa,".")).".chk";
    my $output=substr($nazwa,0,rindex($nazwa,".")).".out";
    make_profile($nazwa,$dir,$profile,$output,$outdir,$db);
  }
}

if ($ARGV[0] eq "-chk2mtx"){
 my $dir=$ARGV[1];
 my $db=$ARGV[2];
 chk2mtx($db,$dir);
}

sub grep_fasta{
  my $base=shift;
  my $uniq=shift;
  my @fasta=open_file(\$base);
  my (@newseq,$title);
  my $lc=0;
  my $found=0;
  foreach my $line(@fasta){
   my $size=@fasta;
   $lc++; 
   if($line =~ m/($uniq)/){
      $found=1;
      $title=$line;
      my @dat=split(/\|/,$title);
      my $name=$dat[1].".fasta";
      open(FILE,">$name");
      next;
   }
   if($found==1){
     unless($line=~/^>/){
       push (@newseq,$line);}
   #if(($line=~/^>/) or ($lc==$size)){
     if($line=~/^>/){
       print FILE "$title\n";
       chomp @newseq;
       my @oldseq= grep /\S/, @newseq;
       print FILE "@oldseq\n";
       undef @newseq;	
       last;
     }
   }
  }
}

sub split_fasta{
  my $base=shift;
  my @fasta=open_file(\$base);
  my (@oldseq,@newseq,$title);
  foreach my $line(@fasta){
    if($line=~/^>/){
      if($#newseq > 0 ){
        print FILE "$title\n";
        chomp @newseq;
        print FILE "@newseq\n";
        undef @newseq;
        undef @oldseq;
      }
      $title=$line;
      my @dat=split(/\|/,$title);
      my $name=$dat[1].".fasta";
      open(FILE,">$name");
    }
   else{
      push (@newseq,$line);
   } 
  }
  print FILE "$title\n";
  chomp @newseq;
  print FILE "@newseq\n";
}

sub split_large_fasta{
  my $base=shift;
  my (@oldseq,@newseq,$title);
  open(FASTA, $base);
  while (<FASTA>) {
    chomp;
    my $line=$_;
    if($line=~/^>/){
      if($#newseq > 0 ){
        print FILE "$title\n";
        chomp @newseq;
        print FILE "@newseq\n";
        undef @newseq;
        undef @oldseq;
      }
      $title=$line;
      my @dat=split(/\|/,$title);
      my $name=$dat[1].".fasta";
      open(FILE,">$name");
    }
    else{
      push (@newseq,$line);
    }
  }
  print FILE "$title\n";
  chomp @newseq;
  print FILE "@newseq\n";

}

sub open_file{
  my ($file_name)=@_;
  open(INP1, "< $$file_name") or die "Can not open an input file: $!";
  my @file1=<INP1>;
  close (INP1);
  chomp @file1;
  return @file1;
}

sub make_profile{
  my $fasta=shift;
  my $dir=shift;
  my $profile=shift;
  my $output=shift;
  my $outputdir=shift;
  my $db=shift;
  #print "blastpgp -j 2 -m 6 -F F -e 1.e-5 -i $dir/$fasta -d $db/nr -C $outputdir/$profile > $outputdir/$output\n";
  `blastpgp -j 2 -m 6 -F F -e 1.e-5 -i $dir/$fasta -d $db/nr -C $outputdir/$profile > $outputdir/$output`
}

sub chk2mtx{
  my $db=shift;
  my $dir=shift;
  chdir "$dir";
  my @prof=`ls -1 *.chk`;
  `ls -1 | grep chk >list`;
  my @prof=`cat list`;
  chomp @prof;
  foreach my $file(@prof){
    my $nfaa=substr($file,0,index($file,".")).".fasta";
    my $nchd=substr($file,0,index($file,".")).".chd";
    my $nchk=substr($file,0,index($file,".")).".chk";
    my $ndb=substr($file,0,index($file,".")).".db";
    copy ("$db/$nfaa","$nchd") or print "file not found $! $nfaa\n";
    `echo "$nchk" >DATABASE.pn`;
    `echo "$nchd" >DATABASE.sn`;
    `makemat -S 1 -P DATABASE`;
    `copymat -r -P DATABASE`;
    `formatdb -i DATABASE -n $ndb`;
  }
  chdir "../";
}









