#!/usr/bin/perl -w
#dziel i rzadz
# w katalogu w ktorym uruchomiony jest program sprawdza czy plik z listy znajduje sie na cotygodniowo aktualizowanej (rcsb) liscie struktur o sekwencji niepowtarzalnej.

#use Cwd;

if ($#ARGV != 2) {die "Program uzywany z parametrami!\
	[lista plikow PDB] [lista plikow z lancuchami] [opcje]\n";}

open(INPUT1, "< $ARGV[0]") or die "Can not open an input file: $!";
open(INPUT2, "< $ARGV[1]") or die "Can not open an input file: $!";
open(OPCJE, "< $ARGV[2]") or die "Can not open an input file: $!";

#wczytanie plików wejsciowych,   
#nazwy plikow PDB w tablicy @lista1
#klastry PDB nonredundant w tablicy @kody

my @lista1=<INPUT1>;
my @kody=<INPUT2>;
close (INPUT1);
close (INPUT2);
chomp @lista1;
chomp @kody;

#wyniki
#katalog z wynikami
#$katalog = cwd;
#$poz=rindex($katalog,'/');
#$dir=substr ($katalog,$poz+1,,);
$wyndir="pdb_chains";
mkdir("$wyndir", 0755) if (! -d "$wyndir");

#zapisanie komunikatów kontrolnych do pliku
$wyniki=$ARGV[0].".out";
open(GOUT,"> $wyniki") or die "Can not write an output file: $!";

#PARAMETRY
#wczytanie opcji 
my @param=<OPCJE>;
close (OPCJE);
chomp @param;
#$ii=0;

$run_dir=`pwd`;
chomp $run_dir;

my %params = ();
foreach $lin(@param){
@para=split(/\s+/,$lin);
$params{$para[0]}=$para[1];
}

while ( my ($key, $value) = each(%params) ) {
 if($key eq 'run_dir'){
 $run_dir=$params{'run_dir'};	
 }
#        print "$key = $value\n";
}

print GOUT "parameters read correctly\n";
print GOUT "results saved in directory: $wyndir\n";
#selekcja lancuchów
#dwa typy plików
#	1.CD-hit, kolumny:  cluster# <tab> rank# <tab> chainID
#	2.blastclust, kazdy wiersz - jeden klaster, od najlepszego do najgorszego
$nl=-1;
if($kody[0]=~/.*\t.*\t.*/){
print GOUT "CD-hit output recognized\n";
}
else{
print GOUT "blastclust output recognized\n";
}

foreach $linia(@kody){
$nl++;
if ($linia=~/.*\t.*\t.*/){
@tab=split(/\t/, $linia);
$best[$nl]=$tab[3];
}
else{
$best[$nl]=substr($linia,0,6);
#print "$best[$nl]\n";
}
}

#analiza plikow pdb po kolei... 
#wczytanie pliku do tablicy
foreach $plik(@lista1){
print GOUT "file analyzed: $plik\n";
	print "$plik\n";
$gdz=rindex($plik,".");
$suff=substr($plik,$gdz,);
#print "$suff\n";
	if($suff eq ".gz" or $suff eq ".Z"){
	print GOUT "file packed, using gzip for unpacking\n";
	`gzip -d $run_dir/$plik`;
	$plik=substr($plik,0,$gdz);
	#print "$plik\n";
	}
open(PDB, "<$run_dir/$plik") or die "Can not open an PDB file: $! $run_dir/$plik";	
my @content=<PDB>;
#print "@content\n";
close (PDB);
`gzip $run_dir/$plik`;


#bierze sekcje ATOM
	$nch=0;
	$num=-1;
	my @chain=();
	foreach $line(@content){
	 if($line=~/^ATOM/){
	 $num++;
	 $chain[$nch][$num]=$line;	
	 }
	 if($line=~/^TER/){
#	 @tabela=split(/\s+/,$chain[$nch][$num]);
	 $chid[$nch]=substr($line,20,2); 
	 $chid[$nch]=~s/\s+//g;
	 $num=-1;
	 $nch++;
	 }
	 if($params{'take_hetatm'}==1){
	  if($line=~/^HETATM/){
	  @tta=split(/\s+/,$line);
	  $chejn=$tta[4];
	   if(substr($line,6,1) ne ' '){
	   print GOUT "WARNING: 1st and 2nd column without separator\n";
	   $chejn=$tta[3];
	   }
	         for $i (0..$nch-1){ 
	 	  if($chejn eq $chid[$i]){ 
		  $tnum=$#{$chain[$i]};
		  $tnum++;
		  $chain[$i][$tnum]=$line;
		  last;
	  	  }
	  	 } 
	 } 	 
	 if($line=~/^MODEL/){
	 print GOUT "WARNING: structure solved with NMR techniques: taking first model only\n";
	 }
	 if($line=~/^ENDMODEL/){
	 last;
	 }
	 }
	}

#sprawdznie ktory lanuch jest nonred

$found=0;
$ll=-1;
for $k (0..$nl){
$wzor=substr($best[$k],0,4);
 if ($plik=~/$wzor/){
$ll++;
$zmn= substr($best[$k],5,1)-1;
$nrchid[$ll]=$chid[$zmn];
 $found=1;
 }
}

#sprawdzenie czy sa identyfiaktory lancuchow
if($found==1){
$znal=0;
 for $p (0..$ll){
	for $i (0..$nch-1){
 	if ($chid[$i] eq $nrchid[$p]){
	$znal=1;
 	$nrchn[$p]=$i;
 	}
 	}	
 	if($znal==0){#identyfikator wybranego lancucha nie pasuje do zadnego znalezionego w bialku
 	printf GOUT "WARNING: no match between nonredundant chain ID and any chain ID in file\n";
 	printf GOUT "Probable reason: no chain identifier, $nch-1 chains in file\n";
 	$nrchid[$p]='A';
 	$nrchn[$p]=0;
	}
 }
}
 if($found==0){
 printf GOUT "WARNING: pdb file not found in non redundant subset\n";
 $nrchid[0]=$chid[0];
 $nrchn[0]=0;
 }

#lancuchy zapisane do plikow
#tylko dla nonredundant
#	$nrchid - identyfikator lancucha NR wzietego z tego bialka
#	$nrchn - numer porzadkowy lancucha NR
if($params{'nr_only'}==1){
$ind=rindex($plik,".");
for $p (0..$ll){
$nrch=$nrchn[$p]; 
 $lancuch=substr($plik,0,$ind)."_".$nrchid[$p].".pdb";
 open(CHAINS,"> $wyndir/$lancuch") or die "Can not write chain-pdb file: $!";
 $czas=localtime(time());
 $usr='wiktor';
 printf CHAINS "REMARK File generated with perl script: krojczy (W.Jurkowski) \n";
 printf CHAINS "REMARK User:  $usr; Time: $czas \n";
 printf CHAINS "REMARK File contains chain: $nrchid[$p] from the PDB file: $plik \n";
 printf CHAINS "REMARK Selected options were used: \n";
 while ( my ($key, $value) = each(%params) ) {
        printf CHAINS "REMARK $key = $value\n";
 }	
	for $n(0..$#{$chain[$nrch]}){
 print CHAINS $chain[$nrch][$n];
	}
 print CHAINS "TER\n";
 print CHAINS "END\n";
 close (CHAINS);
}
}

#wszystkie lancuchy - wynik krojenia
#	nch - liczba lancuchów w danym pliku
#	chid - identyfikator i-tego lancucha
else{
$ind=rindex($plik,".");
 for $i(0..$nch-1){
 $lancuch=substr($plik,0,$ind)."_".$chid[$i].".pdb";
 #$lancuch=$plik."_".$chid[$i];
 #printf "$i\t$lancuch\t$#{$chain[$i]}\n";
 open(CHAINS,"> $wyndir/$lancuch") or die "Can not write chain-pdb file: $!";
 $czas=localtime(time());
 $usr='wiktor';
 printf CHAINS "REMARK File generated with perl script: krojczy (W.Jurkowski) \n";
 printf CHAINS "REMARK User: $usr; Time: $czas \n";
 printf CHAINS "REMARK File contains chain: $chid[$i] from the PDB file: $plik \n";
 printf CHAINS "REMARK Selected options were used: \n";
 while ( my ($key, $value) = each(%params) ) {
        printf CHAINS "REMARK $key = $value\n";
 }
	for $n (0..$#{$chain[$i]}){
 print CHAINS $chain[$i][$n];
	}
 print CHAINS "TER\n";
 print CHAINS "END\n";
 close (CHAINS);
}
}

}



