#!/usr/bin/perl -w
#program zastepujacy beta-faktory w pdb
#parametry programu:[plik PDB] [plik z wartosciami]
if ($#ARGV != 2) {die "Program uzywany z trzema parametrami [plik pdb] [plik z wartosciami] [plik z parametrami]\n";}

    open (PDB, $ARGV[0]) || die "Nie mozna otworzyc pliku $ARGV[0]!\n";
    open (BETA, $ARGV[1]) || die "Nie mozna otworzyc pliku $ARGV[1]!\n"; 
    open(OPCJE, "< $ARGV[2]") or die "Nie mozna otworzyc pliku: $!\n";
    
$gdz=rindex($ARGV[0],".");
$pref=substr($ARGV[0],0,$gdz);
	$output=$pref.".replb.pdb";
    open (OUTPUT, ">$output") || die "Nie mozna otworzyc pliku $output!\n";
    

#wczytanie opcji
my @param=<OPCJE>;
close (OPCJE);
chomp @param;

my %params = ();
foreach $lin(@param){
@para=split(/\s+/,$lin);
$params{$para[0]}=$para[1];
}


    @bialko=<PDB>;
    @val=<BETA>;
    chomp @bialko;
    chomp @val;
    close (PDB);
    close (BETA);
    
        $ll=0;
	$nn=0;
	$ii=0;
	$minv=0;
	$maxv=0;
$czas=localtime(time());
$me =getlogin();	
printf OUTPUT "REMARK File generated with perl script: krojczy (W.Jurkowski) \n";
printf OUTPUT "REMARK User: %s Time: %s\n", $me, $czas;
printf OUTPUT "REMARK Beta factor replaced. \nREMARK New values taken from file: $ARGV[1]\n" ;
printf OUTPUT "REMARK Selected options were used: \n";
while ( my ($key, $value) = each(%params) ) {
printf OUTPUT "REMARK $key = $value\n";
}

	    	
	foreach $linia (@val)
	{
	$nn++;
	@tab=map{ split, $_ } $linia;
#	print "@tab\n";
#	print "$tab[1]\n";
	if($nn == 1){next}
#	$value[$nn-2]=substr ($linia,37,8);
#numer kolumny wziety z opcji
	$value[$nn-2]=$tab[$params{'as_beta'}];
#        print "kkkk,$nn,$value[$nn-2]\n";

	 if($value[$nn-2]>$maxv){
                $maxv=$value[$nn-2];
                }
                if($value[$nn-2]<$minv){
                $minv=$value[$nn-2];
                }
        }
        $minv2 =abs $minv;
	
 	foreach $val(@value)
        {       
        $normv[$ii]=($val+$minv2)/$maxv;
#        print "kkkk,$ii,$val,$normv[$ii]\n";
	$ii++;	
        }
		
	 foreach $dane (@bialko)
	 {
		$info=substr ($dane, 0, 4);
		if ($info eq "ATOM")
		{
		@tab=map{ split, $_ } $dane;
		$atom=$tab[2];
		if ($atom eq "N") {$ll++;}

		$part1= substr($dane, 0, 60);
		$part2=$value[$ll-1];
#wez wartosci znormalizowane jezeli normalized = 1
	if($params{'normalized'}==1)
	{
	$part2=$normv[$ll-1];
	}
		
#ostatnia reszta bez wartosci: nie zwracaj bledu, wypisz czesc 1 wiersza
		if($nn-1< $ll){
#		print "$nn $ll\n";
		print OUTPUT "$part1\n" ;
		next;}		
		
		printf OUTPUT ("%s%6.2f\n",$part1,$part2);
#		printf OUTPUT "$part1$part2\n";
		}
    	 }
	 print OUTPUT "TER\n" ;	
    close(OUTPUT);
