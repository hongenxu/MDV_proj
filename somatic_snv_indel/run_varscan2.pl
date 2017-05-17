#!/usr/bin/perl

use strict;
use warnings;

# see README.md file in the same directory for details

###configuration
my $varscan2="/home/users/xu/varscan-master/VarScan.v2.4.1.jar";
my $tumor_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $normal_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/varscan2_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $bamrc="/home/users/xu/bam_readcount/bin/bam-readcount";
my $vcf2bed="/home/users/xu/MDV_proj/somatic_snv_indel/vcf2bed.pl";




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
    my $cmd1="mkfifo $output_dir/$sample.normal.tumor.fifo";
    my $cmd2="samtools mpileup -f $genome -q 1 -B $normal_bam $tumor_bam > $output_dir/$sample.normal.tumor.fifo \&";
    my $cmd3="java -jar $varscan2 somatic $output_dir/$sample.normal.tumor.fifo --mpileup 1 --output-snp $output_dir/$sample.snp.vcf --output-indel $output_dir/$sample.indel.vcf --output-vcf";
    my $cmd4="rm  $output_dir/$sample.normal.tumor.fifo";
    my $cmd5="java -jar $varscan2 processSomatic $output_dir/$sample.snp.vcf";
    my $cmd6="java -jar $varscan2 processSomatic $output_dir/$sample.indel.vcf";

    ##not used fomr $cmd7 to $cmd12
    #my $cmd7_1="perl $vcf2bed $output_dir/$sample.snp.Somatic.hc.vcf  >$output_dir/$sample.snp.somatic.pos";
    #my $cmd7_2="perl $vcf2bed $output_dir/$sample.snp.LOH.hc.vcf      >$output_dir/$sample.snp.loh.pos";
    #my $cmd7_3="perl $vcf2bed $output_dir/$sample.indel.Somatic.hc.vcf>$output_dir/$sample.indel.somatic.pos";
    #my $cmd7_4="perl $vcf2bed $output_dir/$sample.indel.LOH.hc.vcf    >$output_dir/$sample.indel.loh.pos";
    #my $cmd8_1="$bamrc -b 15 -q 1 -f $genome -l $output_dir/$sample.snp.somatic.pos   $tumor_bam  >$output_dir/$sample.snp.somatic.rc";
    #my $cmd8_2="$bamrc -b 15 -q 1 -f $genome -l $output_dir/$sample.snp.loh.pos       $normal_bam >$output_dir/$sample.snp.loh.rc";
    #my $cmd8_3="$bamrc -b 15 -q 1 -f $genome -l $output_dir/$sample.indel.somatic.pos $tumor_bam  >$output_dir/$sample.indel.somatic.rc";
    #my $cmd8_4="$bamrc -b 15 -q 1 -f $genome -l $output_dir/$sample.indel.loh.pos     $normal_bam >$output_dir/$sample.indel.loh.rc";
    #my $cmd9 ="java -jar $varscan2 fpfilter $output_dir/$sample.snp.LOH.hc.vcf     $output_dir/$sample.snp.loh.rc     --min-var-count 2 --min-var-count-lc 1 --min-var-basequal 15 --min-ref-mapqual 20 --min-var-mapqual 20 --output-file $output_dir/$sample.snp.LOH.hc.filtered.vcf";
    #my $cmd10="java -jar $varscan2 fpfilter $output_dir/$sample.snp.Somatic.hc.vcf $output_dir/$sample.snp.somatic.rc --min-var-count 2 --min-var-count-lc 1 --min-var-basequal 15 --min-ref-mapqual 20 --min-var-mapqual 20 --output-file $output_dir/$sample.snp.Somatic.hc.filtered.vcf";
    #my $cmd11="java -jar $varscan2 fpfilter $output_dir/$sample.indel.LOH.hc.vcf      $output_dir/$sample.indel.loh.rc      --output-file $output_dir/$sample.indel.LOH.hc.filtered.vcf";
    #my $cmd12="java -jar $varscan2 fpfilter $output_dir/$sample.indel.Somatic.hc.vcf  $output_dir/$sample.indel.somatic.rc  --output-file $output_dir/$sample.indel.Somatic.hc.filtered.vcf";

    system "cp ~/template.sh $sample.varscan2.job";
    open OUT, ">>$sample.varscan2.job" or die $!;
    print OUT "$cmd1\n$cmd2\n$cmd3\n$cmd4\n$cmd5\n$cmd6\n";
    #print OUT "$cmd7_1\n$cmd7_2\n$cmd7_3\n$cmd7_4\n";
    #print OUT "$cmd8_1\n$cmd8_2\n$cmd8_3\n$cmd8_4\n";
    #print OUT "$cmd9\n$cmd10\n$cmd11\n$cmd12\n";
    close OUT;
    #then qsub $sample.varscan2.job to the cluster
    #`qsub -b y -q all.q  -N "varscan2$sample" "sh $sample.varscan2.job"`;
}






