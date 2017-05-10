#/usr/bin/perl
#require the config.txt file, we keep a copy in the current directory
#usage:perl fastq2bam.pl --sample sample_id
#we direct the ouputput of this script to a file and then 'qsub' the file to the cluster

use strict;
use warnings;
use Getopt::Long;
use List::MoreUtils qw(uniq);


###parameter and usage for this script

my $sample="";
my $usage="Usage: perl fastq2bam.pl --sample sample_id\nSee the first column of config.txt for possible sample_id value (e.g.,002683_Line-6).\n";
GetOptions(
            "sample=s"   => \$sample);
die $usage if $sample eq "";

###input and output directory configuration

#the location for fastq files
my $input_dir="/home/proj/MDW_genomics/MSU_HPCC_Research/DNA_Seq/Fastq_All_Samples/";

#main output directory
my $output_dir="/scratch/xu/MDV_project/fastq2bam";
#trimmomatic output directory
my $trimm_output="$output_dir/trimm/";
mkdir $trimm_output if ! -d $trimm_output;
#sickle output directory
my $sickle_output="$output_dir/sickle/";
mkdir $sickle_output if ! -d $sickle_output;
#fastqc output directory
my $fastqc_output="$output_dir/fastqc/";
mkdir $fastqc_output if ! -d $fastqc_output;
#bwa output directory
my $bwa_output="$output_dir/bwa/";
mkdir $bwa_output if ! -d $bwa_output;
#post-processing output directory
my $post_output="$output_dir/post_alignment/";
mkdir $post_output if ! -d $post_output;
#merged output directory, for storing final bam file merging all lanes
my $merged_output="$output_dir/merged/";
mkdir $merged_output if ! -d $merged_output;

##softwares and requring files

my $sample_cfg="/home/users/xu/MDV_proj/fastq2bam/config.txt";
my $trimmomatic="/home/users/xu/Trimmomatic-0.35";
my $sickle="/home/users/xu/sickle-1.33/sickle";
my $fastqc="/home/users/xu/FastQC/fastqc";
my $bwa="/home/users/xu/bwa/bwa";
my $reference="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $picard="/home/users/xu/picard-tools-1.141/picard.jar";
my $gatk="/home/users/xu/gatk-3.5";


###read config.txt file

open CFG, "$sample_cfg" or die "Cannot find the sample configure file!\n";
my @barcodes;
my @lanes;
my @reads;
my $file_suffix="";
my $sample_label="";
my $sample_type="";
while (<CFG>){
	chomp;
	next if $_=~/^#/;#ignore comment line
	my ($id,$barcode,$lane,$read,$suffix,$label,$type)=split/\t/,$_;
	if ($id eq $sample ){
		push @barcodes,$barcode;
		push @lanes,$lane;
		push @reads,$read;
		$file_suffix=$suffix;
		$sample_label=$label;
		$sample_type=$type;
		@barcodes=uniq(@barcodes);
		@lanes=uniq(@lanes);
		@reads=uniq(@reads);
	}
}
close CFG;

if ($sample_label eq ""){
	die  "Cannot find sample:$sample in sample configure file $sample_cfg\n";
}



#######################main#############################

if (scalar@reads !=2){
	die "Error in read pairs!\n";
}
if (scalar@barcodes !=1) {
	die "Error in barcodes!\n";
}
my $new_sample=$sample;
if ($sample=~/^017/) {

	$new_sample=~s/017//g;
	$new_sample=join("_",$new_sample,$sample_label);
}
else {

}

my $merge_sam_input="";###used in the last step

foreach my $lane (@lanes){

	#################adapter trimming using Trimmomatic###################################
	my $barcode=$barcodes[0];
	my $tri_in_R1=join("",$input_dir,$sample,"_",$barcode,"_",$lane,"_","R1","_",$file_suffix);
	my $tri_in_R2=join("",$input_dir,$sample,"_",$barcode,"_",$lane,"_","R2","_",$file_suffix);
	if (! -e $tri_in_R1 or ! -e $tri_in_R2 ){
		die "$tri_in_R1"," or ","$tri_in_R2", " not exists!\n";
	}
	$lane=~s/00//g; ###change from "L001" to "L1"

	my $tri_out_R1_paired=join("",$trimm_output,$new_sample,"_",$lane,"_","R1","_","paired_Trimmomatic.fastq.gz");
	my $tri_out_R2_paired=join("",$trimm_output,$new_sample,"_",$lane,"_","R2","_","paired_Trimmomatic.fastq.gz");
	my $tri_out_R1_unpaired=join("",$trimm_output,$new_sample,"_",$lane,"_","R1","_","unpaired_Trimmomatic.fastq.gz");
	my $tri_out_R2_unpaired=join("",$trimm_output,$new_sample,"_",$lane,"_","R2","_","unpaired_Trimmomatic.fastq.gz");

	my $cmd1="java -jar $trimmomatic/trimmomatic-0.35.jar PE -threads 4 $tri_in_R1 $tri_in_R2 $tri_out_R1_paired $tri_out_R1_unpaired $tri_out_R2_paired $tri_out_R2_unpaired ILLUMINACLIP:$trimmomatic/adapters/TruSeq2-PE.fa:2:30:10 HEADCROP:9";
	print "$cmd1\n";

	#####################read trimming using sickle	##########################################
	my $sic_R1_paired=$tri_out_R1_paired;
	my $sic_R1_unpaired=$tri_out_R1_unpaired;
	my $sic_R2_paired=$tri_out_R2_paired;
	my $sic_R2_unpaired=$tri_out_R2_unpaired;
	my $sic_out_R1=join("","$sickle_output",$new_sample,"_",$lane,"_","R1","_","Sickle.fastq.gz");
	my $sic_out_R2=join("","$sickle_output",$new_sample,"_",$lane,"_","R2","_","Sickle.fastq.gz");
	my $sic_out_singles_PE=join("","$sickle_output",$new_sample,"_",$lane,"_","Singles_PE_Sickle.fastq.gz");
	my $sic_out_singles_SE=join("","$sickle_output",$new_sample,"_",$lane,"_","Singles_SE_Sickle.fastq.gz");
	my $cmd2="$sickle pe -f $sic_R1_paired -r $sic_R2_paired -t sanger -o $sic_out_R1 -p $sic_out_R2 -s $sic_out_singles_PE -q 20 -l 50 -g";
	my $cmd3="$sickle se -f $sic_R1_unpaired -t sanger -o $sic_out_singles_SE -q 30 -l 50 -g";

	print "$cmd2\n";
	print "$cmd3\n";

	##########################fastqc post sickle trimming###################################
	my $fas_in_R1=$sic_out_R1;
	my $fas_in_R2=$sic_out_R2;
	my $fas_in_singles_PE=$sic_out_singles_PE;
	my $fas_in_singles_SE=$sic_out_singles_SE;
	my $cmd4="$fastqc -o $fastqc_output $fas_in_R1 $fas_in_R2 $fas_in_singles_PE $fas_in_singles_SE";
	print "$cmd4\n";

	#########################read aligner bwa #####################################################
	my $bwa_in_R1=$sic_out_R1;
	my $bwa_in_R2=$sic_out_R2;
	my $bwa_in_singles_PE=$sic_out_singles_PE;
	my $bwa_in_singles_SE=$sic_out_singles_SE;##will not be used due to failure to pass fastqc
	my $bwa_out_sam=join("",$bwa_output,$new_sample,"_",$lane,"_","Bwa_NRG_Yet.sam");
    my $cmd5="$bwa mem -t 11 -T 20 $reference $bwa_in_R1 $bwa_in_R2 >$bwa_out_sam";

	print "$cmd5\n";


	########################### post-processing using picard and gatk###############################
	###Add ReadGroups using picard####

    my $pic_in_sam=$bwa_out_sam;
	my $pic_out_sam=join("",$post_output,$new_sample,"_",$lane,"_","Bwa_ReadGroups.sam");
	my $new_lane=$lane;
	$new_lane=~s/L/lane/g; ##change "L1" to "lane1"
	my $RGID=join("_",$new_sample,$new_lane);
	my $RGPL="Illumina";
	my $RGPU=join("_",$barcode,$new_lane);
	my $RGSM=$new_sample;
	my $RGLB=$sample_type;
	my $cmd6="java -Xmx40g -jar $picard AddOrReplaceReadGroups INPUT=$pic_in_sam OUTPUT=$pic_out_sam RGID=$RGID RGPL=$RGPL RGPU=$RGPU RGSM=$RGSM RGLB=$RGLB";
	print "$cmd6\n";


    ########further post-processing, including sorting, marking duplicates, indel realignment

	my $RG_sam_by_lane=join("",$post_output,$new_sample,"_",$lane,"_","Bwa_ReadGroups.sam");
	my $RG_bam_by_lane=join("",$post_output,$new_sample,"_",$lane,"_","Bwa_RG.bam");
	my $bam_by_lane_marked=join("",$post_output,$new_sample,"_",$lane,"_","Bwa_RG_marked.bam");
	my $metrix_file_by_lane=join("",$post_output,$new_sample,"_",$lane,"_","Dedup_by_lane_Metrics.txt");
	my $bam_by_lane_marked_index=join("",$post_output,$new_sample,"_",$lane,"_","Bwa_RG_marked.bai");
	my $Intervals_by_lane=join("",$post_output,$new_sample,"_",$lane,"_","Intervals_by_lane.list");
	my $Realinged_bam_by_lane=join("",$post_output,$new_sample,"_",$lane,"_","Realinged_bam_by_lane.bam");

	my $cmd7="java -Xmx40g -jar $picard SortSam INPUT=$RG_sam_by_lane OUTPUT=$RG_bam_by_lane SORT_ORDER=coordinate";
	my $cmd8="java -Xmx40g -jar $picard MarkDuplicates INPUT=$RG_bam_by_lane OUTPUT=$bam_by_lane_marked METRICS_FILE=$metrix_file_by_lane MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000";
	my $cmd9="java -Xmx40g -jar $picard BuildBamIndex INPUT=$bam_by_lane_marked OUTPUT=$bam_by_lane_marked_index";
	my $cmd10="java -Xmx40g -cp $gatk -jar $gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $GalGal5_Ref -I $bam_by_lane_marked -o $Intervals_by_lane";
	my $cmd11="java -Xmx40g -cp $gatk -jar $gatk/GenomeAnalysisTK.jar -T IndelRealigner -R $GalGal5_Ref -I $bam_by_lane_marked -targetIntervals $Intervals_by_lane -o $Realinged_bam_by_lane";

	print "$cmd7\n";
	print "$cmd8\n";
	print "$cmd9\n";
	print "$cmd10\n";
	print "$cmd11\n";

	my $sam_lane=join("","INPUT=",$post_output,$new_sample,"_",$lane,"_","Realinged_bam_by_lane.bam");
	$merge_sam_input=join(" ",$merge_sam_input,$sam_lane);

}

#print "\n$merge_sam_input\n";

my $merged_bam=join("",$merged_output,$new_sample,"_","all_lanes_merged_Bwa_RG.bam");
my $merged_bam_index=join("",$merged_output,$new_sample,"_","all_lanes_merged_Bwa_RG.bai");
my $marked_merged_bam=join("",$merged_output,$new_sample,"_","merged_sorted_Bwa_RG_marked.bam");
my $marked_merged_bam_index=join("",$merged_output,$new_sample,"_","merged_sorted_Bwa_RG_marked.bai");
my $metrix_file_across_lanes=join("",$merged_output,$new_sample,"_","Dedup_across_lanes_Metrics.txt");
my $Intervals_across_lanes=join("",$merged_output,$new_sample,"_","Intervals_across_lanes.list");
my $Dedupped_realigned_merged_BAM=join("",$merged_output,$new_sample,"_","Bwa_RG_dedupped_realigned.bam");
my $Dedupped_realigned_merged_BAM_index=join("",$merged_output,$new_sample,"_","Bwa_RG_dedupped_realigned.bai");

#merge BAM files from all lanes
print "java -Xmx40g -jar $picard MergeSamFiles  $merge_sam_input OUTPUT=$merged_bam AS=true";
print "\n";
#index BAM file
print "java -Xmx40g -jar $picard BuildBamIndex INPUT=$merged_bam OUTPUT=$merged_bam_index";
print "\n";
#mark duplicates
print "java -Xmx40g -jar $picard MarkDuplicates INPUT=$merged_bam OUTPUT=$marked_merged_bam METRICS_FILE=$metrix_file_across_lanes MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000";
print "\n";
#index BAM files
print "java -Xmx40g -jar $picard BuildBamIndex INPUT=$marked_merged_bam OUTPUT=$marked_merged_bam_index";
print "\n";
#indel realignment
print "java -Xmx40g -cp $gatk -jar $gatk/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $GalGal5_Ref -I $marked_merged_bam -o $Intervals_across_lanes" ;
print "\n";
print "java -Xmx40g -cp $gatk -jar $gatk/GenomeAnalysisTK.jar -T IndelRealigner -R $GalGal5_Ref -I $marked_merged_bam -targetIntervals $Intervals_across_lanes -o $Dedupped_realigned_merged_BAM";
print "\n";
#index BAM files
print "java -Xmx40g -jar $picard BuildBamIndex  INPUT=$Dedupped_realigned_merged_BAM OUTPUT=$Dedupped_realigned_merged_BAM_index";
print "\n";

