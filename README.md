# MDV project
Scripts used in MDV project. 

Most of these scripts were only used to generate commands, and we redirected those commands to a file and submitted (qsub) the file to our computer cluster.

&copy;Hongen XU, Frishman Lab, TUM
##Fastq2bam pipeline
Scripts were uesd to process original FASTQ files to final BAM files. The pipeline was designed following GATK best practice.
* [Details](fastq2bam/README.md)

##Identify somatic SNVs and Indels
We used SomaticSeq to identify somatic SNVs and Indels because SomaticSeq placed #1 and #2 in INDEL and SNV in the Stage 5 of the ICGC-TCGA DREAM Somatic Mutation Calling Challenge.
* [Details](somatic_snv_indel/README.md)

##Identify somatic SVs
* [Details](somatic_sv/README.md)

##Identify significantly mutated genes/regions

