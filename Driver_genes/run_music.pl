#!/usr/bin/perl
#===============================================================================
#
#         FILE:  run_music.pl
#
#        USAGE:  ./run_music.pl
#
#  DESCRIPTION:  run genome MuSiC
#
# REQUIREMENTS:  ---
#        NOTES:  ---
#       AUTHOR:  Hongen XU (HX), hongen_xu@hotmail.com
#      COMPANY:  TUM
#      VERSION:  1.0
#      CREATED:  03/03/2016 02:02:30 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

###configuration
my $music="/home/users/xu/perl5/bin/genome";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/home/proj/MDW_genomics/xu/driver_genes/music_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $gff="/home/proj/MDW_genomics/xu/galgal5/GCF_000002315.4_Gallus_gallus-5.0_genomic.gff";
my $nc_vs_chrs="/home/proj/MDW_genomics/xu/galgal5/nc_vs_chrs.txt";
##correspoding NCBI idS for chromosome 1,2,....
my $chr_sizes="/home/proj/MDW_genomics/xu/galgal5/chr.sizes";
my $maf="/home/proj/MDW_genomics/xu/driver_genes/myMAF.tsv";

##sample identifiers
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");

###create roi-file used by "genome music bmr calc-covg"

##notes from genome music
#The regions of interest (ROIs) of each gene are typically regions targeted for sequencing
#or are merged exon loci (from multiple transcripts) of genes with 2-bp flanks (splice junctions).
#ROIs from the same chromosome must be listed adjacent to each other in this file.
#This allows the underlying C-based code to run much more efficiently and avoid re-counting bases seen in
#overlapping ROIs (for overall covered base counts).
#For per-gene base counts, an overlapping base will be counted each time it appears in an ROI of the same gene.
#To avoid this, be sure to merge together overlapping ROIs of the same gene.
#BEDtools' mergeBed can help if used per gene.


my %hash;
open NC_VS_CHRS,"$nc_vs_chrs" or die $!;
while (<NC_VS_CHRS>){
    chomp;
    my ($nc,$chr)=split/\t/,$_;
    $hash{$nc}=$chr;
}
close NC_VS_CHRS;


open EXON,">$output_dir/exons.txt" or die $!;
open GFF,"$gff" or die $!;
while (<GFF>){
    chomp;
    next if $_=~/^#/;
    @_=split/\t/,$_;
    my $id=$_[0];
    my $type=$_[2];
    my $start=$_[3];
    my $end=$_[4];
    my $annotation=$_[8];
    my $gene="";
    if ($annotation=~/;gene\=(\w+);/){
        $gene=$1;
    }
    next if $gene eq "";

    if ($type eq "exon"){
        if (exists $hash{$id}){
            $id=$hash{$id};
        }
        else {
            print "Error! Please check $id\n" if $id=~/NC/;
        }
        print EXON "$id\t$start\t$end\t$gene\n";
    }
}
close GFF;
close EXON;

#exon file  looks like
##sample from https://raw.githubusercontent.com/ding-lab/calc-roi-covg/master/data
#/ensembl_67_cds_ncrna_and_splice_sites_hg19
#1	1108434	1111778	TTLL10-AS1
#1	1109262	1109308	TTLL10
#1	1109899	1110416	TTLL10
#1	1114594	1114715	TTLL10
#1	1114743	1114937	TTLL10-AS1

print "exon files generated\n";


##changed to BED format---start is 0 based
`awk '{print \$1"\t"\$2-1"\t"\$3"\t"\$4}' $output_dir/exons.txt >$output_dir/exons.bed`;

###add 2-bp flanks at both sides of each exons
system "bedtools slop -i $output_dir/exons.bed -g $chr_sizes -b 2 >$output_dir/exons_2bp.bed";


##for exons of a single gene, sort and merge
`awk '{print > \$4".tmp"}' $output_dir/exons_2bp.bed`;


my @files=<*.tmp>;

system "rm $output_dir/exons_2bp.merged.bed";
foreach my $file (@files){
    `bedtools sort -i $file >$file.sorted`;
    system "rm $file";
    `bedtools merge -i $file.sorted -c 4 -o distinct >$file.sorted.merged`;
    system "cat $file.sorted.merged >>$output_dir/exons_2bp.merged.bed";
    system "rm $file.sorted";
    system "rm $file.sorted.merged";
}
###final sort
system "bedtools sort -i $output_dir/exons_2bp.merged.bed >$output_dir/exons_2bp.merged.sorted.bed";


#change back to 1 based
`awk '{print \$1"\t"\$2+1"\t"\$3"\t"\$4}' $output_dir/exons_2bp.merged.sorted.bed > $output_dir/all_exons.tsv`;

###create bam list file used by "genome music bmr calc-covg"
open BAMLIST, ">$output_dir/bam_list.txt" or die $!;
foreach my $num (0..25){
    my $tumor_bam=join("",$tumor_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    my $normal_bam=join("",$normal_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    print "$tumor_bam not exists\n" if ! -e $tumor_bam;
    print "$normal_bam not exists\n" if ! -e $normal_bam;
    print BAMLIST "$tumors[$num]\t$normal_bam\t$tumor_bam\n";
}
close BAMLIST;



my $cmd1="$music music bmr calc-covg --bam-list $output_dir/bam_list.txt --roi-file $output_dir/all_exons.tsv --output-dir $output_dir --gene-covg-dir $output_dir  --reference-sequence $genome --normal-min-depth 6 --tumor-min-depth 6";
my $cmd2="$music music bmr calc-bmr  --bam-list $output_dir/bam_list.txt --roi-file $output_dir/all_exons.tsv --output-dir $output_dir --bmr-output    $output_dir  --reference-sequence $genome --gene-mr-file $output_dir/gene_covgs/    --maf-file $maf";
my $cmd3="$music music smg           --gene-mr-file $output_dir/gene_mrs --output-file $output_dir/smgs.txt";

print "$cmd1\n$cmd2\n$cmd3\n";





