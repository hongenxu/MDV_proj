#!/usr/bin/perl

#extract SNVs identified by at least n (specified by $tools) tools
#write to file mutations.vcf

use strict;
use warnings;
use Getopt::Long;



my $tools=2;
GetOptions ("tools=i" => \$tools,
)
    or die("Usage: perl ./prepare4somaticsignatures.pl --tools <NUM>\n");
#extract SNVs identified by at least $tools tools

#input file is *.ensemble.snp.vcf
my $input_dir="/home/proj/MDW_genomics/xu/somaticseq";
my $output_dir="/home/proj/MDW_genomics/xu/mut_signature";

chdir $output_dir;


open OUT, ">$output_dir/mutations.vcf" or die $!;
foreach my $i (1..26){
    my $snp_file="$input_dir/S$i.ensemble.snp.vcf";
    open IN, "$snp_file" or die $!;
    while (<IN>){
        chomp;
        next if $_=~/^#/;
        my @eles=split/\t/,$_;
        my $alt=$eles[4];
        next if length($alt)>1;
        if ($_=~/;NUM_TOOLS\=(\d{1})/){
            print OUT "$_\tSample$i\t","MD\n" if $1>=$tools;
        }
    }
    close IN;
}

close OUT;



