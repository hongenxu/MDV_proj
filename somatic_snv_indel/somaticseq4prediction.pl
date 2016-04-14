#/usr/bin/perl 
#===============================================================================
#
#         FILE:  somaticseq.pl
#
#        USAGE:  ./somaticseq.pl  
#
#  DESCRIPTION:  used for model prediction 
#
# REQUIREMENTS:  ---
#        NOTES:  ---
#       AUTHOR:  Hongen XU (HX), hongen_xu@hotmail.com
#      COMPANY:  TUM
#      VERSION:  1.0
#      CREATED:  03/11/2016 06:38:28 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use Getopt::Long;


my $sample="";
my $model="";
my $usage="for model prediction.\nUsage: $0 --sample sample_id --model model\nmodels: F1, S28_duped,or F28_nodup\n";
GetOptions('sample=s' =>\$sample,
           'model=s' =>\$model);
die $usage if $sample eq "" or $model eq "";

## app directory 
my $python="/home/users/xu/miniconda2/envs/py35/bin/python";
my $somaticseq="/home/users/xu/somaticseq-2.0.2";
my $bam_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $samtools="/home/users/xu/bin/samtools";
my $gatk="/home/users/xu/gatk-3.5/GenomeAnalysisTK.jar";
my $genome="/home/users/xu/bwa/galgal5.fa";
my $picard="/home/users/xu/picard-tools-1.141/picard.jar";
my $ref_dict="/home/users/xu/bwa/galgal5.dict";
my $snpEff="/home/users/xu/snpEff";
my $dbSNP="/home/proj/MDW_genomics/xu/dbSNP/dbSNP.galgal5.vcf";
my $snp_model=join("","/home/proj/MDW_genomics/xu/model_train/",$model,".ensemble.snp.tsv.Classifier.RData");
my $indel_model=join("","/home/proj/MDW_genomics/xu/model_train/",$model,".ensemble.indel.tsv.Classifier.RData");

####data input for SNV callers
####calls from SNV callers are assumedly in a same directory 
my $main_in_dir="/home/proj/MDW_genomics/xu/7callers";
my $mutect_dir="$main_in_dir/mutect_results";
my $varscan2_dir="$main_in_dir/varscan2_results";
my $jsm_dir="$main_in_dir/jsm_results";
my $somaticsniper_dir="$main_in_dir/somaticsniper_results";
my $vardict_dir="$main_in_dir/vardict_results";
my $muse_dir="$main_in_dir/muse_results";
#my $mutect2_dir="$main_in_dir/mutect2_results";
my $indelocator_dir="$main_in_dir/indelocator_results";
####output directory 
my $output_dir="/scratch/xu/MDV_project/somaticseq";
mkdir $output_dir if ! -d $output_dir;


my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");

my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");

$sample=~/^S(\d+)/;
my $num=$1;
$num--;
	
my $tumor_bam=join("",$bam_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
my $normal_bam=join("",$bam_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");

#print "$tumor_bam\t$normal_bam\n";


########################mutect#############################
print "touch $mutect_dir/$sample.filtered.vcf\n";
print "grep -v \"REJECT\" $mutect_dir/$sample.vcf >$mutect_dir/$sample.filtered.vcf\n";
print "$python $somaticseq/modify_MuTect.py -type snp  -infile $mutect_dir/$sample.filtered.vcf -outfile $output_dir/$sample.mutect.snp.vcf -nbam $normal_bam -tbam  $tumor_bam -samtools $samtools \n";
print "\n";

#######################varscan2############################
##for both snp and indel
print "$python $somaticseq/modify_VJSD.py -method VarScan2 -infile $varscan2_dir/$sample.snp.Somatic.hc.vcf -outfile $output_dir/$sample.varscan2.snp.vcf \n";
print "$python $somaticseq/modify_VJSD.py -method VarScan2 -infile $varscan2_dir/$sample.indel.Somatic.hc.vcf -outfile $output_dir/$sample.varscan2.indel.vcf \n";
print "\n";

#######################jointsnvmix2########################
#joinsnvmix does not output vcf file 
#so a script in /home/users/xu/somaticseq-2.0.1/Run_5_callers/individual_callers/JSM2VCF.sh was used 
#to convert tsv file to vcf 
print "touch $output_dir/$sample.jsm.tmp.vcf\n";
print "touch $output_dir/$sample.jsm.snp.vcf\n";
print "sh $somaticseq/Run_5_callers/individual_callers/JSM2VCF.sh $jsm_dir/$sample.filtered.tsv > $output_dir/$sample.jsm.tmp.vcf\n";
print "$python $somaticseq/modify_VJSD.py -method JointSNVMix2 -infile $output_dir/$sample.jsm.tmp.vcf -outfile $output_dir/$sample.jsm.snp.vcf\n";
print "\n";

#####################somaticsniper######################## 
print "$python $somaticseq/modify_VJSD.py -method SomaticSniper -infile $somaticsniper_dir/$sample.vcf -outfile $output_dir/$sample.somaticsniper.snp.vcf \n";
print "\n";

####################vardict################################
#Hongen's comments
#var2vcf_paired.pl was used to create vcf files
#see somaticseq manual for details 

print "$python $somaticseq/modify_VJSD.py -method VarDict -infile $vardict_dir/$sample.vcf -outfile $output_dir/$sample.vcf -N \"NORMAL\" -T \"TUMOR\" -filter paired\n";
print "mv $output_dir/snp.$sample.vcf $output_dir/$sample.vardict.snp.vcf\n";
print "mv $output_dir/indel.$sample.vcf $output_dir/$sample.vardict.indel.vcf\n";
print "\n";

##################muse#####################################

print "$python $somaticseq/modify_VJSD.py -method MuSE -infile $muse_dir/$sample.vcf -outfile $output_dir/$sample.muse.snp.vcf\n";
print "\n";

#################mutect2################################
##use mutect2 results instead of indelocator 
##extract header lines
#extract indels, adding CGA tag, extract "PASS" (means somatic)
#mutect2 was deprecated
##for unknown reasons, the output VCF files of the following commands cannot be correctly processed by python scripts in SomaticSeq

#print "grep \"#\" $mutect2_dir/$sample.vcf > $output_dir/$sample.mutect2.indel.vcf\n";
#print qq(sed -i '36i##INFO=<ID=CGA,Number=0,Type=Flag,Description="CGA called somatic event">' $output_dir/$sample.mutect2.indel.vcf\n);
#print qq(awk 'length(\$4)>1 \|\|length(\$5)>1 {print \$1"\\t"\$2"\\t"\$3"\\t"\$4"\\t"\$5"\\t"\$6"\\t"\$7"\\t"\$8"\;CGA""\\t"\$9"\\t"\$10"\\t"\$11}' $mutect2_dir/$sample.vcf |grep "PASS" - >> $output_dir/$sample.mutect2.indel.vcf\n);
#print "\n";

####################indelocator############### 
print "$python $somaticseq/modify_MuTect.py -type indel  -infile $indelocator_dir/$sample.vcf -outfile $output_dir/$sample.indelocator.indel.vcf -nbam $normal_bam -tbam  $tumor_bam -samtools $samtools \n";

################combine SNV callers results################
my @snp_callers=("mutect","varscan2","jsm","somaticsniper","vardict","muse");

foreach my $caller (@snp_callers){
	if (! -e "$output_dir/$sample.$caller.snp.vcf"){
		 
		#die "$output_dir/$sample.$caller.snp.vcf not found\n";
	}
	print "java -jar $picard SortVcf  I=$output_dir/$sample.$caller.snp.vcf O=$output_dir/$sample.$caller.snp.sorted.vcf SEQUENCE_DICTIONARY=$ref_dict\n";
	print "mv $output_dir/$sample.$caller.snp.sorted.vcf $output_dir/$sample.$caller.snp.vcf\n";	
}

print "java -jar $gatk -T CombineVariants -R $genome --setKey null --genotypemergeoption UNSORTED -V $output_dir/$sample.mutect.snp.vcf -V $output_dir/$sample.varscan2.snp.vcf -V $output_dir/$sample.jsm.snp.vcf -V $output_dir/$sample.somaticsniper.snp.vcf -V $output_dir/$sample.vardict.snp.vcf -V $output_dir/$sample.muse.snp.vcf --out $output_dir/$sample.combined.snp.vcf\n";
print "\n";

################combine INDEL callers results ######
my @indel_callers=("indelocator","varscan2","vardict");
foreach my $indel_caller (@indel_callers){
     if (! -e "$output_dir/$sample.$indel_caller.indel.vcf"){
         #die "$output_dir/$sample.$indel_caller.indel.vcf not found\n";
         
     }
     print "java -jar $picard SortVcf  I=$output_dir/$sample.$indel_caller.indel.vcf O=$output_dir/$sample.$indel_caller.indel.sorted.vcf SEQUENCE_DICTIONARY=$ref_dict\n";
     print "mv $output_dir/$sample.$indel_caller.indel.sorted.vcf $output_dir/$sample.$indel_caller.indel.vcf\n";
 }

print "java -jar $gatk -T CombineVariants -R $genome --setKey null --genotypemergeoption UNSORTED -V $output_dir/$sample.indelocator.indel.vcf -V $output_dir/$sample.varscan2.indel.vcf  -V $output_dir/$sample.vardict.indel.vcf --out $output_dir/$sample.combined.indel.vcf\n";
print "\n";

###############################snpEff annotation using dbSNP##### 

print "java -jar $snpEff/SnpSift.jar annotate $dbSNP $output_dir/$sample.combined.snp.vcf |java -jar $snpEff/snpEff.jar Galgal5.00 - >$output_dir/$sample.EFF.dbSNP.combined.snp.vcf\n";
print "java -jar $snpEff/SnpSift.jar annotate $dbSNP $output_dir/$sample.combined.indel.vcf |java -jar $snpEff/snpEff.jar Galgal5.00 - >$output_dir/$sample.EFF.dbSNP.combined.indel.vcf\n";
print "\n";
################################adding tool names into the SOURCES in the INFO
print "$python $somaticseq/score_Somatic.Variants.py  -tools CGA VarScan2 JointSNVMix2 SomaticSniper VarDict MuSE -infile $output_dir/$sample.EFF.dbSNP.combined.snp.vcf  -mincaller 1 -outfile $output_dir/$sample.bina.somatic.snp.vcf\n ";

print "$python $somaticseq/score_Somatic.Variants.py  -tools CGA VarScan2 VarDict -infile $output_dir/$sample.EFF.dbSNP.combined.indel.vcf  -mincaller 1 -outfile $output_dir/$sample.bina.somatic.indel.vcf\n";
print "\n";

#####################Convert the VCF file and annotate ##########
print "$python $somaticseq/SSeq_merged.vcf2tsv.py -ref $genome -myvcf $output_dir/$sample.bina.somatic.snp.vcf  -mutect $mutect_dir/$sample.filtered.vcf  -varscan $varscan2_dir/$sample.snp.Somatic.hc.vcf  -jsm $output_dir/$sample.jsm.tmp.vcf  -sniper $somaticsniper_dir/$sample.vcf  -vardict $output_dir/$sample.vardict.snp.vcf -muse $muse_dir/$sample.vcf  -tbam $tumor_bam -nbam $normal_bam -outfile $output_dir/$sample.ensemble.snp.tsv\n"; 

print "$python $somaticseq/SSeq_merged.vcf2tsv.py -ref $genome -myvcf $output_dir/$sample.bina.somatic.indel.vcf -mutect $indelocator_dir/$sample.vcf  -varscan $varscan2_dir/$sample.indel.Somatic.hc.vcf -vardict $output_dir/$sample.vardict.indel.vcf -tbam $tumor_bam -nbam $normal_bam -outfile $output_dir/$sample.ensemble.indel.tsv\n";

###prediction
#print "R --no-save --args $snp_model $output_dir/$sample.ensemble.snp.tsv $output_dir/$sample\_$model.trained.snp.tsv  <$somaticseq/r_scripts/ada_model_predictor.R \n";
#print "R --no-save --args $indel_model $output_dir/$sample.ensemble.indel.tsv $output_dir/$sample\_$model.trained.indel.tsv <$somaticseq/r_scripts/ada_model_predictor.R \n";

#print "$python $somaticseq/SSeq_tsv2vcf.py -tsv $output_dir/$sample\_$model.trained.snp.tsv -vcf $output_dir/$sample\_$model.trained.snp.vcf -pass 0.7 -low 0.1 -tools CGA VarScan2 JointSNVMix2 SomaticSniper VarDict MuSE -all -phred\n";
#print "$python $somaticseq/SSeq_tsv2vcf.py -tsv $output_dir/$sample\_$model.trained.indel.tsv -vcf $output_dir/$sample\_$model.trained.indel.vcf  -pass 0.7 -low 0.1 -tools CGA VarScan2  VarDict  -all -phred\n";


###remove intermediate files  
foreach my $caller (@snp_callers){
	print "rm $output_dir/$sample.$caller.snp*\n";		
}
foreach my $caller (@indel_callers){
	print "rm $output_dir/$sample.$caller.indel*\n";		
}

print "rm $output_dir/$sample.jsm.tmp.vcf \n";
print "rm $output_dir/$sample.combined.snp* \n";
print "rm $output_dir/$sample.combined.indel* \n";
print "rm $output_dir/$sample.EFF.dbSNP.combined.snp* \n";
print "rm $output_dir/$sample.EFF.dbSNP.combined.indel* \n";

