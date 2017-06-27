#!/usr/bin/perl

#extract copycat results to results.copycat.txt

use strict;
use warnings;

my $wd="/home/proj/MDW_genomics/xu/scna/copycat_results/";
chdir $wd;

###copycat raw output files were in this directory
my $input_dir="/scratch/xu/MDV_project/copycat_results";



##sample identifiers
#the first tumor match the first normal...
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");


open OUT, ">results.copycat.txt" or die $!;
foreach my $num (0..25){
    $tumors[$num]=~/.*(S\d+)/;
    my $sample=$1;
    my $new_sample=$tumors[$num];
    open RESULT,"$input_dir/$sample/alts.paired.dat" or die $!;
    while (<RESULT>){
        chomp;
        my ($chr,$start,$end,$a,$copy)=split/\t/,$_;
        my $change="";
        if ($copy>2){
            $change="gain";
        }
        elsif ($copy<2) {
            $change="loss";
        }
        else {
            $change="neutral";
        }
        print OUT "$chr\t$start\t$end\t$change\t$new_sample\n";

    }
    close RESULT;
}
close OUT;




