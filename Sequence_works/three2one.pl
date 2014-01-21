#!/usr/bin/perl -w
#use strict;
#use warnings;
#
if ($#ARGV != 0) {die "Program used with parameters [input file]\n";}

my @inputs=open_file($ARGV[0]);

#output file
open (GOUT, "> $ARGV[0]-trans") or die "Can not create general output file: $!";

foreach my $lin (@inputs){
 if ($lin eq "ALA" or $lin eq "Ala"){printf GOUT "A\n";}
 elsif ($lin eq "ARG" or $lin eq "Arg"){printf GOUT "R\n";}
 elsif ($lin eq "ASN" or $lin eq "Asn"){printf GOUT "N\n";}
 elsif ($lin eq "ASP" or $lin eq "Asp"){printf GOUT "D\n";}
 elsif ($lin eq "CYS" or $lin eq "Cys"){printf GOUT "C\n";}
 elsif ($lin eq "GLN" or $lin eq "Gln"){printf GOUT "Q\n";}
 elsif ($lin eq "GLU" or $lin eq "Glu"){printf GOUT "E\n";}
 elsif ($lin eq "GLY" or $lin eq "Gly"){printf GOUT "G\n";}
 elsif ($lin eq "HIS" or $lin eq "His"){printf GOUT "H\n";}
 elsif ($lin eq "ILE" or $lin eq "Ile"){printf GOUT "I\n";}
 elsif ($lin eq "LEU" or $lin eq "Leu"){printf GOUT "L\n";}
 elsif ($lin eq "LYS" or $lin eq "Lys"){printf GOUT "K\n";}
 elsif ($lin eq "MET" or $lin eq "Met"){printf GOUT "M\n";}
 elsif ($lin eq "PHE" or $lin eq "Phe"){printf GOUT "F\n";}
 elsif ($lin eq "PRO" or $lin eq "Pro"){printf GOUT "P\n";}
 elsif ($lin eq "SER" or $lin eq "Ser"){printf GOUT "S\n";}
 elsif ($lin eq "SEC" or $lin eq "Sec"){printf GOUT "U\n";}
 elsif ($lin eq "THR" or $lin eq "Thr"){printf GOUT "T\n";}
 elsif ($lin eq "TRP" or $lin eq "Trp"){printf GOUT "W\n";}
 elsif ($lin eq "TYR" or $lin eq "Tyr"){printf GOUT "Y\n";}
 elsif ($lin eq "VAL" or $lin eq "Val"){printf GOUT "V\n";}
 else{printf GOUT "$lin\n";}
}

sub open_file{
        my ($file_name)=@_;
        open(INP1, "< $file_name") or die "Can not open an input file: $!";
        my @file1=<INP1>;
        close (INP1);
        chomp @file1;
        return @file1;
}

