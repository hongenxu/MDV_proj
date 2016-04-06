#!/usr/bin/perl

use strict;
use warnings;


###notes here 
#https://github.com/AstraZeneca-NGS/VarDict/issues/2
#here explains why vardict needs input bed files and bed regions are 
#recommended to have 150 bp overlap for WGS data to call indels 
#bed file cand be found in /home/users/xu/VarDict-1.4.4/bin 

###configuration 
my $vardict="/home/users/xu/VarDict-1.4.4/bin";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/vardict_results";
my $genome="/home/users/xu/bwa/galgal5.fa";

##sample identifiers 
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");

my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");


foreach my $num (11){
	my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
	my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
	print "$tumor_bam not exists\n" if ! -e $tumor_bam;
	print "$normal_bam not exists\n" if ! -e $normal_bam;	
	
	$tumors[$num]=~/.*(S\d+)/;
	my $sample=$1;
	
	foreach my $item (1224..1225){
		my $cmd1="$vardict/VarDict -G $genome -b \"$tumor_bam\|$normal_bam\" -th 4 -F 0x500 -z -C -c 1 -S 2 -E 3 -g 4 $vardict/$item.bed  > $output_dir/$sample.vardict.$item";
		
		
		open FILE, ">vd$sample.$item" or die $!;
		print FILE "\#\!\/bin\/bash\n";
		print FILE "$cmd1\n";
		close FILE;

		system "qsub -b y -q lofn-10g.q -l core=4 -N \"$sample.$item\" \"sh /scratch/xu/MDV_project/vd$sample.$item\""; 
	}
	
	
	#my $cmd2="Rscript $vardict/tmp/testsomatic.R $output_dir/$sample.vardict $output_dir/$sample.test";
	#my $cmd3="perl $vardict/var2vcf_paired.pl -f 0.01 $output_dir/$sample.test >$output_dir/$sample.vcf";
##-G  the reference fasta. Should be indexed (.fai).
###-N  The sample name to be used directly. Will overwrite -n option
###-b  The indexed BAM file "/path/to/tumor.bam|/path/to/normal.bam"
###-F  The hexical to filter reads. Default: 0x500 (filter 2nd alignments and duplicates)
###-C  Indicate the chromosome names are just numbers, such as 1, 2, not chr1, chr2
###-c  The column for chromosome
###-S  The column for the region start, e.g. gene start
###-E  The column for the region end, e.g. gene end
###-g  The column for a gene name, or segment annotation
##-z 0/1, -z 1 indicates that coordinates in a BED file start from 0. Default: 1

	#open FILE, ">vd$sample" or die $!;
	#print FILE "\#\!\/bin\/bash\n";
	#print FILE "$cmd1\n";	
	#print FILE "$cmd2\n";
	#print FILE "$cmd3\n";
	#close FILE;
	#`qsub -b y -q lofn-10g.q -l vf=120G,core=60 -N "vd$sample" "sh /scratch/xu/MDV_project/vd$sample"`;		
	
}






