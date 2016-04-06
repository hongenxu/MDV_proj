#!/usr/bin/env bash
#PBS -l nodes=1:ppn=10,walltime=03:59:00,mem=32gb
#PBS -j oe

#-------------------------------------------------------------------------------
# Job Location
#-------------------------------------------------------------------------------

#Laptop
#---------------
#/Users/Alec/Documents/Bioinformatics/MDV_Project/DNASeq_Analysis/Somatic_Snp_Analysis/Germline_Difference/

#HPCC
#---------------
#/mnt/home/steepale/MDV_Project/Jobs/Somatic_Snp_Analysis/Germline_Difference/

#-------------------------------------------------------------------------------
# Documentation
#-------------------------------------------------------------------------------

#Best practices website from Broad
#URL: https://www.broadinstitute.org/gatk/guide/best-practices?bpm=DNAseq#tutorials_mapdedup2799

#PicardTools website
#URL: http://broadinstitute.github.io/picard/

#Objectives:
#Add ReadGroups to the SAM files
#Merge the sam files from each sample by lane
#Sort the SAM files into a finished BAM file
#Index BAM file

#-------------------------------------------------------------------------------
# Citation
#-------------------------------------------------------------------------------

#From: http://broadinstitute.github.io/picard/faq.html
#"Q: How should I cite Picard in my manuscript?
#A: Currently there is no Picard paper. You can cite Picard by referring to the website, http://broadinstitute.github.io/picard."

#Citation:
#http://broadinstitute.github.io/picard

#-------------------------------------------------------------------------------
# Load Modules
#-------------------------------------------------------------------------------

module load picardTools/1.113
#To run any picard tool use 'java -jar $PICARD/toolname.jar'.  For example 'java -jar $PICARD/ViewSam.jar'
#Picardtools uses +1 ppn.  Please request one additional PPN when scheduling picardTools jobs

#-------------------------------------------------------------------------------
# Files
#-------------------------------------------------------------------------------

cd /mnt/scratch/birdman/MDV_project/DNAseq/Somatic_Snp_Analysis/BAM/

declare S
declare BC
declare NS
declare L
declare NL
declare RGL
declare RGS

BC[1]="CGGCTATG-TATAGCC_"
BC[2]="CGGCTATG-ATAGAGG_"
BC[3]="CGGCTATG-CCTATCC_"
BC[4]="CGGCTATG-GGCTCTG_"
BC[5]="TCCGCGAA-TATAGCC_"
BC[6]="TCCGCGAA-ATAGAGG_"
BC[7]="TCCGCGAA-CCTATCC_"
BC[8]="CGCTCATT-TATAGCC_"
BC[9]="CGCTCATT-CCTATCC_"
BC[10]="AGCGATAG-ATAGAGG_"
BC[11]="AGCGATAG-CCTATCC_"
BC[12]="TCCGCGAA-GGCTCTG_"
BC[13]="AGCGATAG-TATAGCC_"

BC[14]="CGGCTATG-AGGCGAA_"
BC[15]="CGGCTATG-TAATCTT_"
BC[16]="CGGCTATG-CAGGACG_"
BC[17]="CGGCTATG-GTACTGA_"
BC[18]="TCCGCGAA-AGGCGAA_"
BC[19]="TCCGCGAA-TAATCTT_"
BC[20]="TCCGCGAA-CAGGACG_"
BC[21]="CGCTCATT-GGCTCTG_"
BC[22]="CGCTCATT-AGGCGAA_"
BC[23]="CGCTCATT-CAGGACG_"
BC[24]="CGCTCATT-GTACTGA_"
BC[25]="TCCGCGAA-GTACTGA_"
BC[26]="CGCTCATT-TAATCTT_"

NS[1]="738-1_S1_"
NS[2]="741-1_S2_"
NS[3]="756-3_S3_"
NS[4]="766-1_S4_"
NS[5]="798-1_S5_"
NS[6]="833-1_S6_"
NS[7]="834-2_S7_"
NS[8]="855-1_S8_"
NS[9]="863-1_S9_"
NS[10]="918_3_S10_"
NS[11]="927-2_S11_"
NS[12]="834-2_2_S12_"
NS[13]="911-1_2_S13_"

NS[14]="777-3_S14_"
NS[15]="787-2_S15_"
NS[16]="788-1_S16_"
NS[17]="794-1_S17_"
NS[18]="835-1_S18_"
NS[19]="841-3_S19_"
NS[20]="842-2_S20_"
NS[21]="884-2_S21_"
NS[22]="901-2_S22_"
NS[23]="906-1_S23_"
NS[24]="911-1_S24_"
NS[25]="842-2_2_S25_"
NS[26]="901-2_2_S26_"

RGS[1]="738-1_S1"
RGS[2]="741-1_S2"
RGS[3]="756-3_S3"
RGS[4]="766-1_S4"
RGS[5]="798-1_S5"
RGS[6]="833-1_S6"
RGS[7]="834-2_S7"
RGS[8]="855-1_S8"
RGS[9]="863-1_S9"
RGS[10]="918_3_S10"
RGS[11]="927-2_S11"
RGS[12]="834-2_2_S12"
RGS[13]="911-1_2_S13"

RGS[14]="777-3_S14"
RGS[15]="787-2_S15"
RGS[16]="788-1_S16"
RGS[17]="794-1_S17"
RGS[18]="835-1_S18"
RGS[19]="841-3_S19"
RGS[20]="842-2_S20"
RGS[21]="884-2_S21"
RGS[22]="901-2_S22"
RGS[23]="906-1_S23"
RGS[24]="911-1_S24"
RGS[25]="842-2_2_S25"
RGS[26]="901-2_2_S26"

NL[1]="L1_"
NL[2]="L2_"
NL[3]="L3_"
NL[4]="L4_"

NL[5]="L5_"
NL[6]="L6_"
NL[7]="L7_"
NL[8]="L8_"

RGL[1]="lane1"
RGL[2]="lane2"
RGL[3]="lane3"
RGL[4]="lane4"

RGL[5]="lane5"
RGL[6]="lane6"
RGL[7]="lane7"
RGL[8]="lane8"

R1="R1_001"
R2="R2_001"

# Control Samples
#----------------------------------------
#steepale@hpcc.msu.edu:/mnt/research/ADOL/Cheng-Lab-Data/common/Steep_DNASeq/Raw_Reads/Controls/

#017842-0_2_CGATGT_L008_R1_001.fastq.gz
#017842-0_2_CGATGT_L008_R2_001.fastq.gz
#017901-0_2_CAGATC_L008_R1_001.fastq.gz
#017901-0_2_CAGATC_L008_R2_001.fastq.gz
#017911-0_GTGAAA_L008_R1_001.fastq.gz
#017911-0_GTGAAA_L008_R2_001.fastq.gz

#steepale@hpcc.msu.edu:/mnt/research/ADOL/Cheng-Lab-Data/archive/20140102_A_DNASeq_PE_6x7-F1/

#6x7-F1_GCCAAT_L001_R1_001.fastq.gz
#6x7-F1_GCCAAT_L001_R2_001.fastq.gz
#6x7-F1_GCCAAT_L002_R1_001.fastq.gz
#6x7-F1_GCCAAT_L002_R2_001.fastq.gz

BC[27]='GCCAAT_' 
BC[28]='CGATGT_'
BC[29]='CAGATC_'
BC[30]='GTGAAA_'

S[27]="6x7-F1_GCCAAT_"
S[28]="017842-0_2_CGATGT_"
S[29]="017901-0_2_CAGATC_"
S[30]="017911-0_GTGAAA_"

NS[27]="6x7-F1_"
NS[28]="842-0_C1_"
NS[29]="901-0_C2_"
NS[30]="911-0_C3_"

RGS[27]="6x7-F1"
RGS[28]="842-0_C1"
RGS[29]="901-0_C2"
RGS[30]="911-0_C3"

#-------------------------------------------------------------------------------
# Path to Programs and Libraries
#-------------------------------------------------------------------------------

loc_input='/mnt/scratch/birdman/MDV_project/DNAseq/Somatic_Snp_Analysis/Bowtie2_Output/'
loc_output="/mnt/scratch/birdman/MDV_project/DNAseq/Somatic_Snp_Analysis/BAM/"
loc_archive='/mnt/research/ADOL/Cheng-Lab-Data/common/Steep_DNASeq/BAM/'

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------

# Tumor Samples
#----------------------------------------

for a in {1..13}
do
    for b in {1..4}
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
    done
done

for a in {1..13}
do
    RG_sam_L1=$loc_input${NS[a]}${NL[1]}'Bowtie2_ReadGroups.sam'
    RG_sam_L2=$loc_input${NS[a]}${NL[2]}'Bowtie2_ReadGroups.sam'
    RG_sam_L3=$loc_input${NS[a]}${NL[3]}'Bowtie2_ReadGroups.sam'
    RG_sam_L4=$loc_input${NS[a]}${NL[4]}'Bowtie2_ReadGroups.sam'
    merged_sam=$loc_input${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.sam'
    merged_bam=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    bam_index=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    archive_merged_bam=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    archive_bam_index=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    java -Xmx10g -jar $PICARD/MergeSamFiles.jar \
        INPUT=$RG_sam_L1 \
        INPUT=$RG_sam_L2 \
        INPUT=$RG_sam_L3 \
        INPUT=$RG_sam_L4 \
        OUTPUT=$merged_sam
    java -Xmx10g -jar $PICARD/SortSam.jar \
        INPUT=$merged_sam \
        OUTPUT=$merged_bam \
        SORT_ORDER=coordinate
    java -Xmx10g -jar $PICARD/BuildBamIndex.jar \
        INPUT=$merged_bam \
        OUTPUT=$bam_index
        rsync $merged_bam $archive_merged_bam
        rsync $bam_index $archive_bam_index
done

for a in {14..26}
do
    for b in {5..8}
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
    done
done

for a in {14..26}
do
    RG_sam_L5=$loc_input${NS[a]}${NL[5]}'Bowtie2_ReadGroups.sam'
    RG_sam_L6=$loc_input${NS[a]}${NL[6]}'Bowtie2_ReadGroups.sam'
    RG_sam_L7=$loc_input${NS[a]}${NL[7]}'Bowtie2_ReadGroups.sam'
    RG_sam_L8=$loc_input${NS[a]}${NL[8]}'Bowtie2_ReadGroups.sam'
    merged_sam=$loc_input${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.sam'
    merged_bam=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    bam_index=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    archive_merged_bam=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    archive_bam_index=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    java -Xmx10g -jar $PICARD/MergeSamFiles.jar \
        INPUT=$RG_sam_L5 \
        INPUT=$RG_sam_L6 \
        INPUT=$RG_sam_L7 \
        INPUT=$RG_sam_L8 \
        OUTPUT=$merged_sam
    java -Xmx10g -jar $PICARD/SortSam.jar \
        INPUT=$merged_sam \
        OUTPUT=$merged_bam \
        SORT_ORDER=coordinate
    java -Xmx10g -jar $PICARD/BuildBamIndex.jar \
        INPUT=$merged_bam \
        OUTPUT=$bam_index
        rsync $merged_bam $archive_merged_bam
        rsync $bam_index $archive_bam_index
done

# Control Samples
#----------------------------------------

for a in {27..27}
do
    for b in {1..2}
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
    done
done

for a in {27..27}
do
    RG_sam_L1=$loc_input${NS[a]}${NL[1]}'Bowtie2_ReadGroups.sam'
    RG_sam_L2=$loc_input${NS[a]}${NL[2]}'Bowtie2_ReadGroups.sam'
    merged_sam=$loc_input${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.sam'
    merged_bam=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    bam_index=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    archive_merged_bam=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    archive_bam_index=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    java -Xmx10g -jar $PICARD/MergeSamFiles.jar \
        INPUT=$RG_sam_L1 \
        INPUT=$RG_sam_L2 \
        OUTPUT=$merged_sam
    java -Xmx32g -jar $PICARD/SortSam.jar \
        INPUT=$merged_sam \
        OUTPUT=$merged_bam \
        SORT_ORDER=coordinate
    java -Xmx32g -jar $PICARD/BuildBamIndex.jar \
        INPUT=$merged_bam \
        OUTPUT=$bam_index
        rsync $merged_bam $archive_merged_bam
        rsync $bam_index $archive_bam_index
done

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
    done
done

for a in {28..30}
do
    RG_sam_L8=$loc_input${NS[a]}${NL[8]}'Bowtie2_ReadGroups.sam'
    merged_sam=$loc_input${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.sam'
    merged_bam=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    bam_index=$loc_output${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    archive_merged_bam=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bam'
    archive_bam_index=$loc_archive${NS[a]}'all_lanes_merged_sorted_Bowtie2_ReadGroups.bai'
    java -Xmx10g -jar $PICARD/SortSam.jar \
        INPUT=$RG_sam_L8 \
        OUTPUT=$merged_bam \
        SORT_ORDER=coordinate
    java -Xmx10g -jar $PICARD/BuildBamIndex.jar \
        INPUT=$merged_bam \
        OUTPUT=$bam_index
        rsync $merged_bam $archive_merged_bam
        rsync $bam_index $archive_bam_index
done

qstat -f ${PBS_JOBID}

#-------------------------------------------------------------------------------
# Test Run
#-------------------------------------------------------------------------------


#Samples 1 sequenced in lane 1
#for a in {1..1}
#    do
#    paired_sam_L1=$loc_input${NS[a]}${NL[1]}'paired_BWA.sam'
#    paired_sam_L2=$loc_input${NS[a]}${NL[2]}'paired_BWA.sam'
#    paired_sam_L3=$loc_input${NS[a]}${NL[3]}'paired_BWA.sam'
#    paired_sam_L4=$loc_input${NS[a]}${NL[4]}'paired_BWA.sam'
#    merged_sam=$loc_input${NS[a]}'all_lanes_merged.sam'
#    merged_bam=$loc_output${NS[a]}'all_lanes_merged_sorted.bam'
#    bam_index=$loc_output${NS[a]}'all_lanes_merged_sorted.bai'
#    java -Xmx60g -jar $PICARD/MergeSamFiles.jar \
#        INPUT=$paired_sam_L1 \
#        INPUT=$paired_sam_L2 \
#        INPUT=$paired_sam_L3 \
#        INPUT=$paired_sam_L4 \
#        OUTPUT=$merged_sam
#    java -Xmx60g -jar $PICARD/SortSam.jar \
#        INPUT=$merged_sam \
#        OUTPUT=$merged_bam \
#        SORT_ORDER=coordinate
#    java -Xmx60g -jar $PICARD/BuildBamIndex.jar \
#        INPUT=$merged_bam \
#        OUTPUT=$bam_index
#    rm $merged_sam
#done

#qstat -f ${PBS_JOBID}

#-------------------------------------------------------------------------------
# Resource Calculation
#-------------------------------------------------------------------------------

#resources_used.cput = 01:32:47
#resources_used.energy_used = 0
#resources_used.mem = 13582100kb = 13.58 gb
#resources_used.vmem = 65317596kb
#resources_used.walltime = 00:57:39

#-------------------------------------------------------------------------------
# Main Job Resources
#-------------------------------------------------------------------------------

#Job Id: 24734218.mgr-04.i
#    Job_Name = 009_Sam_to_Bam_Merge_Sort_Index.sh
#    Job_Owner = steepale@dev-intel10.i
#    resources_used.cput = 209:07:31
#    resources_used.energy_used = 0
#    resources_used.mem = 22123332kb = 22.12gb
#    resources_used.vmem = 65384164kb
#    resources_used.walltime = 48:42:19