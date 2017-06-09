#!/usr/bin/perl
#summarize results from breakdancer

use strict;
use warnings;

my $wd="/home/proj/MDW_genomics/xu/SVs/breakdancer_results/";
chdir $wd;

my @files=<*.diii.filtered>; #*.ctx.filtered output  are empty


open OUT, ">breakdancer.bed" or die $!;
foreach my $file (@files){
    open FILE, "$file" or die $!;
    my ($sample,$diii,$filtered)=split/\./,$file;

    while (<FILE>){
        chomp;
        next if $_=~/^#/;
        my @eles=split/\t/,$_;
        my $reads=$eles[9];
        my $chr1=$eles[0];
        my $start1=$eles[1];

        my $chr2=$eles[3];
        my $start2=$eles[4];
        my $type=$eles[6];
        if ($reads>=5 ){
            if ($type eq "CTX"){#inter-chromosome translocation
                print OUT "$chr1\t$start1\t$start1\t$chr2\t$start2\t$start2\t$sample\t$type\n";
            }
            else {
                $start1--;
                print OUT "$chr1\t$start1\t$start2\t",".\t.\t.\t","$sample\t$type\n";
            }
        }
    }
    close FILE;
}
close OUT;
