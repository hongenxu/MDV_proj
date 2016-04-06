#!/usr/bin/perl

use strict;
use warnings;




###please note that 4 lanes for sample 1-26 are merged together 
###barcode for control: using barcode for matched tumor, breakdancer does not care about this 



##configuration 
my $tumor_dir="/home/proj/MDW_genomics/Steep_DNASeq/BAM/";
my $normal_dir="/home/proj/MDW_genomics/File_Transfer/BAMs/";
my $output_dir="/scratch/xu/MDV_project/addRG_results/";


##sample identifiers 
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918_3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
#my @tumors=("738-1_S1");

my @tumor_bcs=("CGGCTATG-TATAGCC","CGGCTATG-ATAGAGG","CGGCTATG-CCTATCC","CGGCTATG-GGCTCTG","TCCGCGAA-TATAGCC","TCCGCGAA-ATAGAGG","TCCGCGAA-CCTATCC","CGCTCATT-TATAGCC","CGCTCATT-CCTATCC","AGCGATAG-ATAGAGG","AGCGATAG-CCTATCC","TCCGCGAA-GGCTCTG","AGCGATAG-TATAGCC","CGGCTATG-AGGCGAA","CGGCTATG-TAATCTT","CGGCTATG-CAGGACG","CGGCTATG-GTACTGA","TCCGCGAA-AGGCGAA","TCCGCGAA-TAATCTT","TCCGCGAA-CAGGACG","CGCTCATT-GGCTCTG","CGCTCATT-AGGCGAA","CGCTCATT-CAGGACG","CGCTCATT-GTACTGA","TCCGCGAA-GTACTGA","CGCTCATT-TAATCTT");



my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_S28","884-0_S48","901-0_S29","906-0_S49","911-0_S30","842-0_S28","901-0_S29");



foreach my $num (6,12,21){
	my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_all_lanes_merged_sorted_Bowtie2_ReadGroups.bam");
	print "$tumor_bam not exists!\n" if ! -e $tumor_bam;

	my $normal_bam=join("",$normal_dir,$normals[$num],"_Bt2_RG_dedupped_realigned.bam");
	print "$normal_bam not exists!\n" if ! -e $normal_bam;

	my $lane=join("","lane","8");
	my $normal_output=join("",$output_dir,$normals[$num],".bam");
	my $normal_rgid=join("",$normals[$num],"_",$lane);
	

	#`qsub -b y -q all.q -N "job_N_$num" "java -jar /home/users/xu/picard-tools-1.141/picard.jar AddOrReplaceReadGroups INPUT="$normal_bam" OUTPUT="$normal_output"  RGID="$normal_rgid"  RGPL="Illumina"  RGPU="$tumor_bcs[$num]"  RGSM="$normals[$num]"  RGLB="normal""`;
	my $tumor_output=join("",$output_dir,$tumors[$num],".bam");
	my $tumor_rgid=join("",$tumors[$num],"_",$lane);

	#`qsub -b y -q all.q -N "job_T_$num" "java -jar /home/users/xu/picard-tools-1.141/picard.jar AddOrReplaceReadGroups INPUT="$tumor_bam" OUTPUT="$tumor_output"  RGID="$tumor_rgid"  RGPL="Illumina"  RGPU=RGPU="$tumor_bcs[$num]"  RGSM="$tumors[$num]"  RGLB="tumor""`;
	#`qsub -b y -q all.q -N "job_N_$num"
	`/home/users/xu/bin/samtools index -b $normal_output`;
	#`qsub -b y -q all.q -N "job_T_$num" 
	#`/home/users/xu/bin/samtools index -b $tumor_output`;

}







=pod

foreach my $num (8..8){
	
	`java -jar /home/users/xu/picard-tools-1.141/picard.jar AddOrReplaceReadGroups INPUT=842-0_C1.bam OUTPUT=n842-0_C1.bam    RGID="842-0_C1_$lane"  RGPL="Illumina"  RGPU="CGATGT_$lane"  RGSM="842-0_C1"  RGLB="normal"`;
	
}

foreach my $num (5..8){
	my $lane=join("","lane",$num);
	`java -jar /home/users/xu/picard-tools-1.141/picard.jar AddOrReplaceReadGroups INPUT=/home/proj/MDW_genomics/Steep_DNASeq/BAM/842-2_S20_all_lanes_merged_sorted_Bowtie2_ReadGroups.bam OUTPUT=n842-2_S20.bam    RGID="842-2_S20_$lane"  RGPL="Illumina"  RGPU="TCCGCGAA-CAGGACG_$lane"  RGSM="842-2_S20"  RGLB="tumor"`;
	
}





for a in {28..30}
do
    for b in {8..8}
    do
        paired_sam=$loc_input${NS[a]}${NL[b]}'Bowtie2_NRG_Yet.sam'
        RG_sam=$loc_input${NS[a]}${NL[b]}'Bowtie2_ReadGroups.sam'
        java -Xmx10g -jar $PICARD/AddOrReplaceReadGroups.jar \
            INPUT=$paired_sam \
            OUTPUT=$RG_sam \
            RGID=${NS[a]}${RGL[b]} \
            RGPL="Illumina" \
            RGPU=${BC[a]}${RGL[b]} \
            RGSM=${RGS[a]} \
            RGLB="truSeq_nano_DNA_library"


NS[28]="842-0_C1_"
RGL[8]="lane8"
BC[28]='CGATGT_'
RGS[28]="842-0_C1"
