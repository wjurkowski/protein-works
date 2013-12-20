#!/usr/bin/perl -w
#program zastepujacy beta-faktory w pdb
#parametry programu:[plik PDB] [plik z wartosciami]

use warnings;
use strict;

if ($#ARGV!=3) {die "Program uzywany z trzema parametrami [plik pdb] [plik z wartosciami] [plik z parametrami] [offset]\n";}

#reads in pdbs and new values 
open (PDB, $ARGV[0]) || die "Nie mozna otworzyc pliku $ARGV[0]!\n";
open (BETA, $ARGV[1]) || die "Nie mozna otworzyc pliku $ARGV[1]!\n"; 
my @bialko=<PDB>;
my @val=<BETA>;
chomp @bialko;
chomp @val;
close (PDB);
close (BETA);

#wczytanie opcji
open(OPCJE, "< $ARGV[2]") or die "Nie mozna otworzyc pliku: $!\n";
my @param=<OPCJE>;
close (OPCJE);
chomp @param;
my %params = ();
foreach my $lin(@param){
	my @para=split(/\s+/,$lin);
	$params{$para[0]}=$para[1];
}

#output
my $pref=substr($ARGV[0],0,rindex($ARGV[0],"."));
my $output=$pref.".replb.pdb";
open (OUTPUT, ">$output") || die "Nie mozna otworzyc pliku $output!\n";
my $czas=localtime(time());
my $me =getlogin();	
printf OUTPUT "REMARK File generated with replace_beta.pl (W.Jurkowski)\n";
	    	
my $nn=0;
my $bminv=0;
my $bmaxv=0;
my $ominv=0;
my $omaxv=0;
my (@betas,@occup,@onormv,@bnormv);
foreach my $linia (@val){
	my @tab=map{ split, $_ } $linia;
	#if($nn == 1){next;}
	#numer kolumny wziety z opcji
	if($params{'beta'}==1 or $params{'beta'}==2){
		$betas[$nn]=$tab[$params{'as_beta'}];
		if($betas[$nn]>$bmaxv){$bmaxv=$betas[$nn];}
	        if($betas[$nn]<$bminv){$bminv=$betas[$nn];}
	}
	if($params{'beta'}==2){
		$occup[$nn]=$tab[$params{'as_occup'}];
		if($occup[$nn]>$omaxv){$omaxv=$occup[$nn];}
	        if($occup[$nn]<$ominv){$ominv=$occup[$nn];}
	}
	$nn++;
}
$nn=$nn-1;

if($params{'normalized'}==1){	
	my $bminv2 =abs $bminv;
	my $ominv2 =abs $ominv;
  if($params{'beta'}==1 or $params{'beta'}==2){
	my $ii=0;
	foreach my $val(@betas){       
        	$bnormv[$ii]=($val+$bminv2)/$bmaxv;
		$ii++;	
	}
  }
  if($params{'beta'}==2){
	my $ii=0;
	foreach my $val(@occup){       
        	$onormv[$ii]=($val+$ominv2)/$omaxv;
		$ii++;	
	}
  }
}
		
my $ll=0;
my $firstn=1;
my $offset=$ARGV[3];
my ($part1,$part2,$part3,$part4);
foreach my $dane (@bialko){
	if (substr($dane,0,4) eq "ATOM"){
		my @tab=map{split,$_} $dane;
		my $element=$tab[11];
		if($tab[2] eq "N"){
		  if($firstn==0){
			$ll++;			
		  }
		  $firstn=0;
		}
		
		if($params{'beta'}==2){
			$part1=substr($dane,0,54);
			$part2=$occup[$ll-$offset];
			$part3=$betas[$ll-$offset];
			$part4="          ".$element;	
		}
		if($params{'beta'}==1){
			$part1=substr($dane,0,60);
			$part2=$betas[$ll-$offset];
			$part3="          ".$element;
		}
		#wez wartosci znormalizowane jezeli normalized = 1
		if($params{'normalized'}==1){
			if($params{'beta'}==1 or $params{'beta'}==2){$part2=$bnormv[$ll-$offset];}
			if($params{'beta'}==2){
				$part2=$onormv[$ll-$offset];
				$part3=$bnormv[$ll-$offset];
			}
		}
		if($ll>$nn+$offset or $ll<$offset){#ostatnie reszty bez wartosci: wypisz czesc 1 wiersza
			if($params{'beta'}==2){
                        	$part1=substr($dane,0,54);
                        	$part2=0.0;
                        	$part3=0.0;
                        	$part4="          ".$element;
                	}
			if($params{'beta'}==1){
                	        $part1=substr($dane,0,60);
        	                $part2=0.0;
                        	$part3="          ".$element;
	                }

		}			
		#if($ll<$offset){#pierwsze reszty bez wartosci: wypisz czesc 1 wiersza
		#	$part1=substr($dane,0,54);
		#	print OUTPUT "$part1\n" ;
		#	next;
		#}			
		if($params{'beta'}==1){printf OUTPUT ("%s%6.2f%12s\n",$part1,$part2,$part3);}
		if($params{'beta'}==2){printf OUTPUT ("%s%6.2f%6.2f%12s\n",$part1,$part2,$part3,$part4);}
	}
}
print OUTPUT "TER\n" ;	
close(OUTPUT);
