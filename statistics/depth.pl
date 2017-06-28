#!/usr/bin/perl

use strict;
use warnings;


###configuration
my $wd="/home/proj/MDW_genomics/xu/depth/";
my $bam_dir="/home/proj/MDW_genomics/final_bam";
my $output_dir="/scratch/xu/MDV_project/depth";
my $home="/home/users/xu/";
chdir $wd;


##sample identifiers
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_S28","884-0_S48","901-0_S29","906-0_S49");
#please note that two normals are renamed by Alec



###for tumors
foreach my $tumor (@tumors){
    my $tumor_bam=join("",$bam_dir,"/",$tumor,"_Bwa_RG_dedupped_realigned.bam");
    die "$tumor_bam not exists!\n" if ! -e $tumor_bam;
    my $tumor_depth=join("",$output_dir,"/",$tumor,".depth");
    my $tumor_result=join("",$output_dir,"/",$tumor,".result");
    my $cmd1=qq(samtools depth -a $tumor_bam >$tumor_depth);
    my $cmd2=qq(awk '{sum+=\$3}END{print sum/NR}' $tumor_depth >$tumor_result);
    print "$cmd1\n$cmd2\n";
    system "cp $home/template.sh $home/$tumor.depth.job";
    open OUT, ">>$home/$tumor.depth.job" or die $!;
    print OUT "$cmd1\n$cmd2\n";
    close OUT;
    #`qsub -b y -q all.q -N "depth$tumor" "sh ~/$tumor.depth.job"`;
}

##for normals
foreach my $normal (@normals){
    my $normal_bam=join("",$bam_dir,"/",$normal,"_Bwa_RG_dedupped_realigned.bam");
    die "$normal_bam not exists!\n" if ! -e $normal_bam;
    my $normal_depth=join("",$output_dir,"/",$normal,".depth");
    my $normal_result=join("",$output_dir,"/",$normal,".result");
    my $cmd1=qq(samtools depth -a $normal_bam >$normal_depth);
    my $cmd2=qq(awk '{sum+=\$3}END{print sum/NR}' $normal_depth >$normal_result);
    system "cp $home/template.sh $home/$normal.depth.job";
    open OUT, ">> $home/$normal.depth.job" or die $!;
    print OUT "$cmd1\n$cmd2\n";
    close OUT;
    #`qsub -b y -q all.q -N "depth$normal" "sh ~/$normal.depth.job"`;
}





