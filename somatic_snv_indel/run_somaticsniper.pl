#!/usr/bin/perl

use strict;
use warnings;


###configuration
#ss is short for somaticsniper
my $ss="/home/users/xu/somatic-sniper/build/bin/bam-somaticsniper";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/somaticsniper_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $samtools="/home/users/xu/samtools-0.1.12/samtools";
my $snpfilter="/home/users/xu/somatic-sniper/src/scripts/snpfilter.pl";
my $preparerc="/home/users/xu/somatic-sniper/src/scripts/prepare_for_readcount.pl";
my $readcount="/home/users/xu/bam_readcount/bin/bam-readcount";
my $fpfilter="/home/users/xu/somatic-sniper/src/scripts/fpfilter.pl";


##sample identifiers
#the first tumor match the first normal
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");


foreach my $num (0..25){
    my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    die "$tumor_bam not exists\n" if ! -e $tumor_bam;
    die "$normal_bam not exists\n" if ! -e $normal_bam;

    $tumors[$num]=~/.*(S\d+)/;
    my $sample=$1;
    my $cmd1="$ss -q 1 -Q 20 -s 0.01 -F vcf -f $genome $tumor_bam $normal_bam $output_dir/$sample.vcf";
    my $cmd2="$samtools pileup -cvi -f $genome $tumor_bam >$output_dir/$sample.pileup";
    my $cmd3="perl $snpfilter --snp-file $output_dir/$sample.vcf --indel-file $output_dir/$sample.pileup --out-file $output_dir/$sample.filtered.vcf";
    my $cmd4="perl $preparerc --snp-file $output_dir/$sample.filtered.vcf --out-file $output_dir/$sample.pos";
    my $cmd5="$readcount -b 15 -q 1 -f $genome -l $output_dir/$sample.pos $tumor_bam >$output_dir/$sample.rc";
    my $cmd6="perl $fpfilter --snp-file $output_dir/$sample.filtered.vcf --readcount-file $output_dir/$sample.rc";

    print "$cmd1\n$cmd2\n$cmd3\n$cmd4\n$cmd5\n$cmd6\n";


}


