#!/usr/bin/perl -w
use strict;
use warnings;
use Bio::AlignIO;

#Two files are needed: 1) uniprot sequence 2) sequence as in pdb
if ($#ARGV != 1) {die "Program used with parameters [uniprot fasta] [pdb fasta]\n";}

#open sequences in fasta format
my $uniprot=open_file($ARGV[0]);
my $pdb=open_file($ARGV[1]);
my $motiflen=$ARGV[2];

$uniprot=~s/\n//g;
$pdb=~s/\n//g;
my @uniseq = split(,$uniprot);
my @pdbseq = split(,$pdb);

my @smotif=split(,substr($uniprot));

my $matched="NO";
my $offset=0;
for (my $k=0;$k<=@#pdbseq;$k++){
	for ($i=0;$i<=@#uniseq;$i++){
			if($pdbseq[$k] eq $uniseq[$i]){
				my $n=0;
				while($n<=$motiflen;$n++){
				  if($pdbseq[$k+$n] eq $uniseq[$i+$n]){
					$matched="YES";
				  }
				  else{
					$matched="NO";
				  }			
				}
				if($matched eq "YES"){
					$offset=$i-$k;
					print "offset = $offset\n";
					jump;
				}		
			}
	}
} 

my $filec = substr($ARGV[1],0,rindex($ARGV[1],"."));
my $file = $filec."-pdb2uniprot.txt";
open(OUT, "> $file") or die "Can not open an output file: $!";
for (my $k=0;$k<=@pdbseq;$k++){
	my $num=$k+1+$offset;
	printf OUT "$$num\tpdbseq[$k]\n";
}

#my $in  = Bio::AlignIO->new(-file => "inputfilename" ,
#                         -format => 'fasta');
#my $out = Bio::AlignIO->new(-file => ">outputfilename",
#                         -format => 'pfam');
#while ( my $aln = $in->next_aln ) { 
#  $out->write_aln($aln); 
#}

#align sequences with blast (use bioperl)
#$factory = Bio::Tools::Run::StandAloneBlast->new(-outfile => 'bl2seq.out');
#$bl2seq_report = $factory->bl2seq($uniprot, $pdb);

## Use AlignIO.pm to create a SimpleAlign object from the bl2seq report
#$str = Bio::AlignIO->new(-file   => 'bl2seq.out',
#                         -format => 'bl2seq');
#$aln = $str->next_aln();

sub open_file{
    my ($file_name)=@_;
    open(INP1, "< $file_name") or die "Can not open an input file: $!";
    my $file1=<INP1>;
    close (INP1);
    chomp $file1;
    return $file1;
}