# MDV project
Scripts used in MDV project. 

Most of these scripts were only used to generate commands, and we redirected those commands to a file and submitted (qsub) the file to our computer cluster.

##Fastq2bam pipeline

##Identify somatic SNVs and Indels
###SNVs
1. MuSE
  * Version:   MuSEv1.0rc_c039ffa
  * From:      http://bioinformatics.mdanderson.org/main/MuSE#Download
  * Parameter: MuSE call –O Output.Prefix –f Reference.Genome Tumor.bam Matched.Normal.bam & MuSE sump -I Output.Prefix.MuSE.txt -G –O Output.Prefix.vcf –D dbsnp.vcf.gz
  * Filtering: No
  * Notes:     dbSNP VCF (Galgal5 version) was used, and see dbSNP_liftover step for details.    
2. MuTect
  * Version:   MuTect-1.1.7, built from source
  * From:      https://github.com/broadinstitute/mutect
  * Parameter: java -jar mutect-1.1.7.jar --analysis_type MuTect  --reference_sequence genome --input_file:tumor tumor_bam --input_file:normal normal_bam --out  output_dir/sample.classical.out --coverage_file output_dir/sample.cov.out --vcf output_dir/sample.vcf
  * Filtering: No
  * Notes:     No
3. MuTect2
  * Version:   MuTect2 is inclued in GATK (version 3.5 and above), GATK version 3.5 was used
  * From:      https://www.broadinstitute.org/gatk/download/
  * Parameter: java -jar GenomeAnalysisTK.jar --analysis_type MuTect2  --reference_sequence genome --input_file:tumor tumor_bam --input_file:normal normal_bam --out  output_dir/sample.vcf
  * Filtering: No
  * Notes:     Not included in SomaticSeq.
4. JointSNVMix2
5. SomaticSniper
  * Version:   V1.0.5.0, from release
  * From:      https://github.com/genome/somatic-sniper
  * Parameter: bam-somaticsniper -q 1 -Q 20 -s 0.01 -F vcf -f reference_genome tumor_bam normal_bam out.vcf
  * Filtering: Basic filtering scripts were provided, but filtering was not used in SomaticSeq, so I decided not to use the filtering.
  * Notes:     No
6. VarDict
7. VarScan2
  * Version:   VarScan.v2.4.1.jar
  * From:      https://github.com/dkoboldt/varscan
  * Parameter: step 1: samtools mpileup -f genome.fa -q 20 -B normal.bam tumor.bam >normal.tumor.fifo &; step 2: java -jar VarScan.v2.4.1.jar somatic normal.tumor.fifo --mpileup 1 --output-snp output.snp.vcf --output-indel  output.indel.vcf --output-vcf; 
  * Filtering: 
  * Notes:     See http://dkoboldt.github.io/varscan/ for usage. & see https://www.biostars.org/p/123430/ for "NOT RESETTING NORMAL error using Varscan2" 
8. SomaticSeq

###Indels
* MuTect2
* Indelocator
* VarDict
* VarScan2

##Identify somatic SVs

##Identify significantly mutated genes/regions

