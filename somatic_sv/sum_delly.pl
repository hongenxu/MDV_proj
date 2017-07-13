#!/usr/bin/perl
#summarize results from delly

use strict;
use warnings;

my $wd="/home/proj/MDW_genomics/xu/SVs/delly_results/";
chdir $wd;


my @types=("DUP","DEL","INV","TRA");

open OUT, ">delly.bed" or die $!;
foreach my $i (1..26){
    foreach my $type (@types){
        my $file=join(".","S$i",$type,"vcf.out");
        if (-e $file ){
        open  FILE,"$file" or die $!;
        while (<FILE>){
            chomp;
            next if $_=~/^#/;
            my @lines=split/\t/,$_;
		        my $chr1=$lines[0];
		        my $start1=$lines[1];
		        $lines[4]=~/\<(.*)\>/;
                my $type=$1;
		        my $info=$lines[7];
                $info=~/CHR2=(.*);END=(\d+);/;
                my $chr2=$1;
                my $start2=$2;

                if ($type eq "TRA"){
                    if ($chr1 eq $chr2){
                        $type="ITX"; #rename "TRA" to "ITX" or "CTX" for the sake of consistence
                        $start1--;
                        print OUT "$chr1\t$start1\t$start2\t",".\t.\t.\t","S$i\t$type\n";
                    }
                    else {
                        $type="CTX"; #interchromosomal translocations
                        print OUT "$chr1\t$start1\t$start1\t$chr2\t$start2\t$start2\t","S$i\t$type\n";                        }
                }

                else{
                    $type="INS" if $type eq "DUP"; #rename "DUP" to "INS" for consistence
                    $start1--;
                    print OUT "$chr1\t$start1\t$start2\t",".\t.\t.\t","S$i\t","$type\n";
                }
        }
            close FILE;


        }

    }
}


close OUT;


