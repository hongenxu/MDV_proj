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
  * Version:   
4. JointSNVMix2
4. SomaticSniper
6. VarDict
7. VarScan2
8. SomaticSeq

###Indels
* MuTect2
* Indelocator
* VarDict
* VarScan2

##Identify somatic SVs

##Identify significantly mutated genes/regions

