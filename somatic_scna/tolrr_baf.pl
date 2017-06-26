#!/usr/bin/perl
#split a file with LRR and BAF values into a single file with LRR and a single file with BAF

use strict;
use warnings;


#working directory
my $wd="/home/proj/MDW_genomics/xu/microarray/output/";

chdir "$wd";

my @files=<MDV.*>;

foreach my $file (@files){

    `sort  -k2,2 -k3,3 $file -V -s >sorted.$file`;
    open FILE, "sorted.$file" or die $!;
    my ($MDV,$sample)=split/\./,$file;
    open LRR, ">../lrr_baf/$sample.LRR" or die $!;
    open BAF, ">../lrr_baf/$sample.BAF" or die $!;
    while (<FILE>){
        chomp;
        next if $_=~/^Name/;
        my ($name,$chr,$pos,$lrr,$baf)=split/\t/,$_;
        $chr=~tr/Z/X/;#rename "Z" to "X"
        print LRR "$name\t$chr\t$pos\t$lrr\n";
        print BAF "$name\t$chr\t$pos\t$baf\n";
    }
    close FILE;
    close LRR;
    close BAF;
    system "rm sorted.$file";
}





