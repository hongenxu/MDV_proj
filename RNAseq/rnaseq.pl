#!/usr/bin/perl
#===============================================================================
#
#         FILE:  rnaseq.pl
#
#        USAGE:  ./rnaseq.pl  --sample 017733
#
#  DESCRIPTION: this script is not simply follow GATK best practice
#  				also considered RECOMMENDATIONS in STAR manual
#
#				GATK RNAseq calling best practice
#				http://gatkforums.broadinstitute.org/gatk/discussion/3891/calling-variants-in-rnaseq
# REQUIREMENTS:  ---
#        NOTES:  ---
#       AUTHOR:  Hongen XU (HX), hongen_xu@hotmail.com
#      COMPANY:  TUM
#      VERSION:  1.0
#      CREATED:  03/16/2016 10:30:50 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Getopt::Long;
use List::MoreUtils qw(uniq);


####software configuration
my $input_dir="/mnt/research/ADOL/OutsideCollaborations/20160201_Cheng_Steep_Xu_Zhang/RNA_seq/data/reads/";
my $output_dir="/mnt/scratch/hongenxu/RNAseq";
my $sample_cfg="/mnt/home/hongenxu/RNAseq/config.txt";
my $star="/mnt/home/hongenxu/softwares/STAR-2.5.1b/bin/Linux_x86_64_static/STAR";
### STAR versions
#versionSTAR             020201
#int>0: STAR release numeric ID. Please do not change this value!
#versionGenome           020101 020200
#genomeint>0: oldest value of the Genome version compatible with this STAR release. Please do not change this value!
my $trimm="/mnt/home/hongenxu/softwares/Trimmomatic-0.35";
my $sortmerna="/mnt/home/hongenxu/softwares/sortmerna-2.1"; #used for removing rRNA in reads
my $seqtk="/mnt/home/hongenxu/softwares/seqtk";


##gene annotations, highly recommended to provide to STAR, see STAR manual for details
my $genome="/mnt/home/hongenxu/softwares/bwa/galgal5.fa";
my $gtf="/mnt/home/hongenxu/softwares/dbSNP/genes.gtf";
my $picard="/mnt/home/hongenxu/softwares/picard-tools-1.141/picard.jar";
my $gatk="/mnt/home/hongenxu/softwares/gatk-3.6/GenomeAnalysisTK.jar";
my $dbSNP="/mnt/home/hongenxu/softwares/dbSNP/dbSNP.galgal5.vcf";


my $rRNA_output="$output_dir/rRNA/";
mkdir $rRNA_output if ! -d $rRNA_output;
my $trimm_output="$output_dir/trimm/";
mkdir $trimm_output if ! -d $trimm_output;
my $genomeDir="$output_dir/genomeDir";
mkdir $genomeDir if ! -d $genomeDir;
my $star_output="$output_dir/STAR/";
mkdir $star_output if ! -d $star_output;

my $sample="";
GetOptions(
            "sample=s"   => \$sample);

#######################handle config.txt file #################################
open CFG, "$sample_cfg" or die "Cannot find the sample configure file!\n";
my @barcodes;
my @lanes;
my @reads;
my $file_suffix="";
my $sample_type="";
while (<CFG>){
	chomp;
	my ($id,$barcode,$lane,$read,$suffix,$type)=split/\t/,$_;
	$sample_type=$type;
	if ($id eq $sample ){
		push @barcodes,$barcode;
		push @lanes,$lane;
		push @reads,$read;
		$file_suffix=$suffix;
		@barcodes=uniq(@barcodes);
		@lanes=uniq(@lanes);
		@reads=uniq(@reads);
	}
}
close CFG;

if (scalar@reads !=2){

	die "Error in read pairs!\n";
}
if (scalar@barcodes !=1) {
	die "Error in barcodes!\n";
}

############################################main############################################
###for all samples, generate genome index files once
#see 1pass.sub for details
#my $cmd0="$star --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles $genome --runThreadN 8 --sjdbGTFfile $gtf --sjdbOverhang 124";
#print "$cmd0\n";


my $merge_bam_input="";###used in the last step

foreach my $lane (@lanes){
	my $barcode=$barcodes[0];
	my $fq_in_R1=join("",$input_dir,$sample,"_",$barcode,"_",$lane,"_","R1","_",$file_suffix);
	my $fq_in_R2=join("",$input_dir,$sample,"_",$barcode,"_",$lane,"_","R2","_",$file_suffix);
	if (! -e $fq_in_R1 or ! -e $fq_in_R2  ){
    	die qq($fq_in_R1 or $fq_in_R2 not exist\n);
	}
	my $fq_inter=join("",$rRNA_output,$sample,"_",$barcode,"_",$lane,".fq");
	my $fq_other=join("",$rRNA_output,$sample,"_",$barcode,"_",$lane,".other");
	my $fq_align=join("",$rRNA_output,$sample,"_",$barcode,"_",$lane,".align");
	my $fq_out_R1=join("",$rRNA_output,$sample,"_",$barcode,"_",$lane,"_","R1",".gz");
	my $fq_out_R2=join("",$rRNA_output,$sample,"_",$barcode,"_",$lane,"_","R2",".gz");

	my $cmd0_1="$seqtk/seqtk mergepe $fq_in_R1 $fq_in_R2 >$fq_inter";
	my $cmd0_2="$sortmerna/sortmerna -a 8 --ref $sortmerna/rRNA_databases/silva-bac-16s-id90.fasta,$sortmerna/index/silva-bac-16s-db:$sortmerna/rRNA_databases/silva-bac-23s-id98.fasta,$sortmerna/index/silva-bac-23s-db:$sortmerna/rRNA_databases/silva-arc-16s-id95.fasta,$sortmerna/index/silva-arc-16s-db:$sortmerna/rRNA_databases/silva-arc-23s-id98.fasta,$sortmerna/index/silva-arc-23s-db:$sortmerna/rRNA_databases/silva-euk-18s-id95.fasta,$sortmerna/index/silva-euk-18s-db:$sortmerna/rRNA_databases/silva-euk-28s-id98.fasta,$sortmerna/index/silva-euk-28s:$sortmerna/rRNA_databases/rfam-5s-database-id98.fasta,$sortmerna/index/rfam-5s-db:$sortmerna/rRNA_databases/rfam-5.8s-database-id98.fasta,$sortmerna/index/rfam-5.8s-db --reads $fq_inter --other $fq_other --aligned $fq_align --log  -v --paired_in --fastx";
	my $cmd0_3="$seqtk/seqtk seq -1 $fq_other.fq |gzip >$fq_out_R1";
	my $cmd0_4="$seqtk/seqtk seq -2 $fq_other.fq |gzip >$fq_out_R2";
	my $cmd0_5="rm $fq_inter $fq_other.fq";
	print "$cmd0_1\n$cmd0_2\n$cmd0_3\n$cmd0_4\n$cmd0_5\n";

	my $tri_out_R1_pe=join("",$trimm_output,$sample,"_",$lane,"_","R1","_","paired.fastq.gz");
    my $tri_out_R2_pe=join("",$trimm_output,$sample,"_",$lane,"_","R2","_","paired.fastq.gz");
    my $tri_out_R1_un=join("",$trimm_output,$sample,"_",$lane,"_","R1","_","unpaired.fastq.gz");
    my $tri_out_R2_un=join("",$trimm_output,$sample,"_",$lane,"_","R2","_","unpaired.fastq.gz");
	my $cmd1="java -jar $trimm/trimmomatic-0.35.jar PE -threads 8 $fq_out_R1 $fq_out_R2 $tri_out_R1_pe $tri_out_R1_un $tri_out_R2_pe $tri_out_R2_un ILLUMINACLIP:$trimm/adapters/TruSeq3-PE.fa:2:30:10";
	print "$cmd1\n";
    ########################per-sample 2-pass mapping
    #use --twopassMode Basic option. STAR will perform the 1st pass mapping,
    #then it will automatically extract junctions, insert them into the genome index, and, finally, re-map
    #all reads in the 2nd mapping pass, see STAR manual for details


	my $paired_rs_out=join("",$star_output,$sample,"_",$lane,"_","paired_");#rs means reads
	my $cmd2="$star --twopassMode Basic --genomeDir $genomeDir  --readFilesIn $tri_out_R1_pe $tri_out_R2_pe  --readFilesCommand zcat --outFileNamePrefix $paired_rs_out --runThreadN 8 --outFilterMultimapNmax 10 sjdbOverhang 124";


	print "$cmd2\n\n";
    ########################adding read group and mark duplicates
	my $paired_rs_sam=join("",$paired_rs_out,"Aligned.out.sam");
	my $paired_rs_bam=join("",$star_output,$sample,"_",$lane,".merged.bam");

	my $cmd3="java -Xmx32g -jar $picard SamFormatConverter I=$paired_rs_sam O=$paired_rs_bam";
	print "$cmd3\n\n";

	print "rm $paired_rs_sam\n\n";
	my $rg_bam=join("",$star_output,$sample,"_",$lane,".merged.RG.bam");
	my $RGID=join("_",$sample,$lane);
	my $RGLB=$sample_type;
	my $RGPL="ILLUMINA";
	my $RGSM=$sample;
	my $RGPU=join("_",$barcode,$lane);
	my $cmd4="java -Xmx32g -jar $picard AddOrReplaceReadGroups I=$paired_rs_bam  O=$rg_bam SO=coordinate RGID=$RGID RGLB=$RGLB RGPL=$RGPL RGSM=$RGSM RGPU=$RGPU";
	print "$cmd4\n\n";

	my $dedupped_bam=join("",$star_output,$sample,"_",$lane,".merged.RG.dedupped.bam");
	my $metrics=join("",$star_output,$sample,"_",$lane,".metrics.txt");
	my $cmd5="java -Xmx32g -jar $picard MarkDuplicates I=$rg_bam  O=$dedupped_bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$metrics";
	print "$cmd5\n\n";
    ####################Split'N'Trim and reassign mapping qualities

	my $split_bam=join("",$star_output,$sample,"_",$lane,".merged.RG.dedupped.split.bam");
	my $cmd6="java -Xmx32g -jar $gatk -T SplitNCigarReads -R $genome -I $dedupped_bam -o $split_bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS";
	print "$cmd6\n\n";

    #################Indel Realignment (optional)
	my $indel_intervals=join("",$star_output,$sample,"_",$lane,".indel.intervals");
	my $cmd7_1="java -Xmx32g -jar $gatk -T RealignerTargetCreator -R $genome -I $split_bam  -o $indel_intervals";

	my $realigned_bam=join("",$star_output,$sample,"_",$lane,".merged.RG.dedupped.split.realigned.bam");
	my $cmd7_2="java -Xmx32g -jar $gatk -T IndelRealigner -R $genome -I $split_bam  -targetIntervals $indel_intervals -o $realigned_bam";
	print "$cmd7_1\n\n$cmd7_2\n\n";

    #######################Base Quality Score Recalibration (BQSR)
	my $bqsr=join("",$star_output,$sample,"_",$lane,".bqsr.table");
	my $bqsr_bam=join("",$star_output,$sample,"_",$lane,".merged.RG.dedupped.split.realigned.bqsr.bam");
	my $cmd8_1="java -Xmx32g -jar $gatk -T BaseRecalibrator -R $genome -I $realigned_bam -knownSites $dbSNP -o $bqsr";
	my $cmd8_2="java -Xmx32g -jar $gatk -T PrintReads 		-R $genome -I $realigned_bam -BQSR       $bqsr	-o $bqsr_bam";
	print "$cmd8_1\n\n$cmd8_2\n\n";

	my $bam_lane=join("","INPUT=",$star_output,$sample,"_",$lane,".merged.RG.dedupped.split.realigned.bqsr.bam");
	$merge_bam_input=join(" ",$merge_bam_input,$bam_lane);

}

my $merged_bam=join("",$star_output,$sample,"_","all_lanes_merged.bam");
my $dedupped_bam=join("",$star_output,$sample,"_","merged.dedupped.bam");
my $metrics=join("",$star_output,$sample,"_","metrics.txt");
my $split_bam=join("",$star_output,$sample,"_","merged.dedupped.splited.bam");
my $indel_intervals=join("",$star_output,$sample,"_","indel.intervals");
my $realigned_bam=join("",$star_output,$sample,"_","merged.dedupped.split.realigned.bam");
my $bqsr=join("",$star_output,$sample,"_","bqsr.table");
my $bqsr_bam=join("",$star_output,$sample,".bam");
my $bqsr_bai=join("",$star_output,$sample,".bai");

my $cmd_m1="java -Xmx32g -jar $picard MergeSamFiles $merge_bam_input O=$merged_bam";
print "$cmd_m1\n\n";
my $cmd_m2="java -Xmx32g -jar $picard MarkDuplicates I=$merged_bam  O=$dedupped_bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=$metrics";
print "$cmd_m2\n\n";
my $cmd_m3="java -Xmx32g -jar $gatk -T SplitNCigarReads -R $genome -I $dedupped_bam -o $split_bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS";
print "$cmd_m3\n\n";
my $cmd_m4="java -Xmx32g -jar $gatk -T RealignerTargetCreator -R $genome -I $split_bam  -o $indel_intervals";
print "$cmd_m4\n\n";
my $cmd_m5="java -Xmx32g -jar $gatk -T IndelRealigner -R $genome -I $split_bam  -targetIntervals $indel_intervals -o $realigned_bam";
print "$cmd_m5\n\n";
my $cmd_m6="java -Xmx32g -jar $gatk -T BaseRecalibrator -R $genome -I $realigned_bam -knownSites $dbSNP -o $bqsr";
print "$cmd_m6\n\n";
my $cmd_m7="java -Xmx32g -jar $gatk -T PrintReads      -R $genome -I $realigned_bam  -BQSR  $bqsr -o $bqsr_bam";
print "$cmd_m7\n\n";
my $cmd_m8="java -Xmx32g -jar $picard BuildBamIndex INPUT=$bqsr_bam OUTPUT=$bqsr_bai";
print "$cmd_m8\n\n";

my $rm1=join("",$star_output,$sample,"_*.bam");
my $rm2=join("",$star_output,$sample,"_*.bai");
print "rm $rm1\n";
print "rm $rm2\n";

