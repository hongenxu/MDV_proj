# MDV project
Scripts used in MDV project. 

Most of these scripts were only used to generate commands, and we redirected those commands to a file and submitted (qsub) the file to our computer cluster.

&copy;Hongen XU, Frishman Lab, TUM

## Prerequisite files

#### Galgal5 reference genome
We used chicken reference genome Galgal5. Genome sequece was downloaded from ftp://ftp.ncbi.nih.gov/genomes/refseq/vertebrate_other/Gallus_gallus/latest_assembly_versions/GCF_000002315.4_Gallus_gallus-5.0/. See https://github.com/hongenxu/MDV_proj/blob/master/make_galgal5_reference.pl for details.


#### dbSNP_liftover
The chicken dbSNP file was based on genome version Galgal4. So we need first liftover galgal4 coordinates to galgal5 ones. 

Since UCSC does not have Galgal4 to Galgal5 chain file, we created own chain file following the guide at https://github.com/wurmlab/flo

#### SnpEff database galgal5.00
We followed the guidance at http://snpeff.sourceforge.net/SnpEff_manual.html#databases to build custom SnpEff database from GTF file. See https://github.com/hongenxu/MDV_proj/blob/master/build_snpEff.pl for details.

#### Variant Effect Predictor database 
We followed the guidance at http://www.ensembl.org/info/docs/tools/vep/script/vep_cache.html  section Building a cache from a GTF or GFF file to build custom VEP database from GFF file. See https://github.com/hongenxu/MDV_proj/blob/master/build_vep.sh for details.

## Fastq2bam pipeline
Scripts were uesd to process original FASTQ files to final BAM files. The pipeline was designed following GATK best practice.
* [Details](https://github.com/hongenxu/MDV_proj/tree/master/fastq2bam)

## Identify somatic SNVs and Indels
We used SomaticSeq to identify somatic SNVs and Indels because SomaticSeq placed #1 and #2 in INDEL and SNV in the Stage 5 of the ICGC-TCGA DREAM Somatic Mutation Calling Challenge.
* [Details](https://github.com/hongenxu/MDV_proj/tree/master/somatic_snv_indel)

## Identify somatic SCNAs
* [Details](https://github.com/hongenxu/MDV_proj/tree/master/somatic_scna)

## Identify somatic SVs
* [Details](https://github.com/hongenxu/MDV_proj/tree/master/somatic_sv)

## Identify somatic SNVs and Indels from RNAseq data
* [Details](RNAseq/README.md)

## Identify significantly mutated genes/regions
* [Details](driver_genes/README.md)


