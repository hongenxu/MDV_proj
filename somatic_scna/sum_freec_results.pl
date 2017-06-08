#!/usr/bin/perl
#this script was used to summarize control-freec output
#extract somatic CNAs and LOH to results.freec.txt
#extract germline CNAs and LOH to germline.cnv

use strict;
use warnings;

open SOMATIC, ">results.freec.txt" or die $!;
open GERMLINE,">germline.cnv" or die $!;

my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");


foreach my $num (1..26){

    my $file=join("","S",$num,".tumor.pileup.gz_CNVs.p.value.txt");#files from control-freec
    open FILE, "$file" or die $!;
    my $sample="";
    while (<FILE>){
        my @eles=split/\t/,$_;
        if ($eles[6] ne "-1" and $eles[7] eq "somatic" and ($eles[9]<0.05 or $eles[10]<0.05)){
            $sample=$tumors[$num-1];
            $eles[0]=~tr/X/Z/; #change X back to Z chromosome
            print SOMATIC "$eles[0]\t$eles[1]\t$eles[2]\t$eles[4]\t","$sample\n";
        }
        if ($eles[6] ne "-1" and $eles[7] eq "germline" and ($eles[9]<0.05 or $eles[10]<0.05)){
            $eles[0]=~tr/X/Z/;#change X back to Z chromsome
            print GERMLINE "$eles[0]\t$eles[1]\t$eles[2]\t$eles[4]\t","S$num\n";
        }
    }
    close FILE;
}

close SOMATIC;
close GERMLINE;



