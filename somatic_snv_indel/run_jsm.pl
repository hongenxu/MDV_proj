#!/usr/bin/perl

use strict;
use warnings;


###configuration
my $jsm="/home/users/xu/.local/bin/jsm.py";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/jsm_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $config="/home/users/xu/JointSNVMix-0.7.5/config";


##sample identifiers
#the first tumor match the first normal ...
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");


foreach my $num (0..25){
    my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    die "$tumor_bam not exists\n" if ! -e $tumor_bam;
    die "$normal_bam not exists\n" if ! -e $normal_bam;
    $tumors[$num]=~/.*(S\d+)/;
    my $sample=$1;
    #for sample 798-1_S5,change --convergence_threshold from default value (0.000001) to 0.01 see README.md file in the same directory for details
    #my $cmd1="$jsm train joint_snv_mix_two --min_normal_depth 8 --min_tumour_depth 6 --convergence_threshold 0.01 $genome $normal_bam $tumor_bam $config/joint_priors.cfg $config/joint_params.cfg $output_dir/$sample.cfg ";
    my $cmd1="$jsm train joint_snv_mix_two --min_normal_depth 8 --min_tumour_depth 6 --convergence_threshold 0.000001 $genome $normal_bam $tumor_bam $config/joint_priors.cfg $config/joint_params.cfg $output_dir/$sample.cfg ";
    my $cmd2="$jsm classify joint_snv_mix_two $genome $normal_bam $tumor_bam $output_dir/$sample.cfg $output_dir/$sample.tsv";
    my $cmd3=qq(awk -F \"\\t\" 'NR!=1 && \$4!="N" && \$10+\$11>=0.95' $output_dir/$sample.tsv >$output_dir/$sample.filtered.tsv);#filtering to reduce file size
    system "cp ~/template.sh $sample.jsm.job";
    open OUT, ">>$sample.jsm.job" or die $!;
    print OUT "$cmd1\n$cmd2\n$cmd3\n";
    close OUT;
    #them qsub $sample.jsm.job to the cluster
}


