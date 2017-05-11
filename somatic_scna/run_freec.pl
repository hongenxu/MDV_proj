#!/usr/bin/perl

use strict;
use warnings;


###software locations and required files
my $freec="/home/users/xu/FREEC-9.8b";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/freec_results";
my $assess="/home/users/xu/FREEC-9.8b/scripts/assess_significance.R";#included in control-freec package
my $ref="/home/proj/MDW_genomics/xu/scna/freec/galgal5.fa";
my $regions="/home/proj/MDW_genomics/xu/scna/freec/bedfile4Control-freec.bed";


##sample identifiers
#the first tumor match the first normal...
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");
my @genders=("ZW","ZZ","ZZ","ZZ","ZZ","ZZ","ZW","ZW","ZZ","ZW","ZW","ZW","ZZ","ZW","ZZ","ZW","ZZ","ZW","ZW","ZW","ZW","ZZ","ZW","ZZ","ZW","ZZ");


foreach my $num (0..25){
    my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    print "$tumor_bam not exists\n" if ! -e $tumor_bam;
    print "$normal_bam not exists\n" if ! -e $normal_bam;

    $tumors[$num]=~/.*(S\d+)/;
    my $sample=$1;
    my $gender=$genders[$num];
    #print "$sample\t$gender\t";
    $gender=~tr/ZW/XY/;
    #print "$gender\n";
    my $tumor_reheader="$output_dir/$sample.tumor.bam";
    my $normal_reheader="$output_dir/$sample.normal.bam";
    #change BAM file header: Z to X, W to Y
    my $cmd1="samtools view -H $tumor_bam  |sed -e 's/SN:W/SN:Y/g' |sed -e 's/SN:Z/SN:X/g' |sed -e 's/SN:/SN:chr/g' |samtools reheader - $tumor_bam >$tumor_reheader ";
    my $cmd2="samtools view -H $normal_bam |sed -e 's/SN:W/SN:Y/g' |sed -e 's/SN:Z/SN:X/g' |sed -e 's/SN:/SN:chr/g' |samtools reheader - $normal_bam >$normal_reheader";
    #create mpileup files used for control-freec
    my $tumor_pileup="$output_dir/$sample.tumor.pileup.gz";
    my $normal_pileup="$output_dir/$sample.normal.pileup.gz";
    my $cmd3="samtools mpileup -q 1 -f $ref -l $regions $tumor_reheader | gzip >$tumor_pileup";
    my $cmd4="samtools mpileup -q 1 -f $ref -l $regions $normal_reheader| gzip >$normal_pileup";
    # remove chrY
    my $cmd5="zcat $tumor_pileup |sed  '/chrY/d' |gzip >/scratch/xu/MDV_project/$sample.tumor.pileup.gz ";
    my $cmd6="zcat $tumor_pileup |sed  '/chrY/d' |gzip >/scratch/xu/MDV_project/$sample.normal.pileup.gz ";

    #create config file
    my $config="~/$sample.config";
    system "cp $freec/config_WGS.txt $config";
    `sed -i 's+mateFile\=sample+mateFile\=$tumor_pileup+g'   $config`;
    `sed -i 's+mateFile\=control+mateFile\=$normal_pileup+g' $config`;
    `sed -i 's+sex\=XY+sex\=$gender+g'  $config`;
    my $cmd7="cd $output_dir/";
    my $cmd8="$freec/freec -conf $config";
    my $cmd9="cat $assess | R --slave --args $output_dir/$sample.tumor.pileup.gz_CNVs $output_dir/$sample.tumor.pileup.gz_ratio.txt ";

    system "cp ~/template.sh ~/$sample.sh";
    open OUT, ">>/home/users/xu/$sample.sh" or die $!;
    print OUT "$cmd1\n$cmd2\n$cmd3\n$cmd4\n";
    print OUT "$cmd5\n$cmd6\n";
    print OUT "$cmd7\n$cmd8\n$cmd9\n";
    close OUT;
    #`qsub -b y -q all.q -N "freec_$sample" "sh ~/$sample.sh"`;

}



