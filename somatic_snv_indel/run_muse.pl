#!/usr/bin/perl

use strict;
use warnings;


###configuration
my $muse="/home/users/xu/MuSEv1.0rc_c039ffa";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/muse_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $dbsnp="/home/proj/MDW_genomics/xu/dbSNP/dbSNP.galgal5.vcf.gz";
##sample identifiers
#the first tumor matched the first normal....
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");


foreach my $num (0..25){
    my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    die "$tumor_bam not exists\n" if ! -e $tumor_bam;
    die "$normal_bam not exists\n" if ! -e $normal_bam;
    $tumors[$num]=~/.*(S\d+)/;
    my $sample=$1;
    my $cmd1="$muse call -f $genome  -O $output_dir/$sample $tumor_bam $normal_bam";
    my $cmd2="$muse sump -I $output_dir/$sample.MuSE.txt -G -D $dbsnp -O $output_dir/$sample.vcf";
    system "cp ~/template.sh ./$sample.sh";
    open OUT, ">>./$sample.sh";
    print OUT "$cmd1\n";
    print OUT "$cmd2\n";
    close OUT;
    #`qsub -b y -q all.q -l vf=8G,core=1 -N "muse$sample" "sh ./$sample.sh"`;
}


