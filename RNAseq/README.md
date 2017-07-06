
# Calling SNVs and Indels from RNAseq data
This pipeline was used to align reads to transcriptome as well as  call SNVs and Indels, and it's not simply follow GATK best practics
and also considered RECOMMENDATIONS in STAR manual.

## Mapping reads to transcriptome and genome

### Software versions
* Trimmomatic-0.35, http://www.usadellab.org/cms/?page=trimmomatic
* FastQC v0.11.4, http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
* STAR 2.5.1b, https://github.com/alexdobin/STAR/releases
* Picard-tools-1.141, http://broadinstitute.github.io/picard/
* GATK-3.6, https://www.broadinstitute.org/gatk/download/
* SortMeRNA v2.1, http://bioinfo.lifl.fr/RNA/sortmerna/
### Explanations

* config.txt 

required for running `rnaseq.pl`

* `rnaseq.pl`

main script 

* `submit.pl`

running `rnaseq.pl` and submit the job to computer cluster

### Notes:

Two samples 017824 and 017748 failed in the GATK "SplitNCigarReads" with error message "Badly formed genome location: Parameters to GenomeLocParser are incorrect". This bug will only be fixed in GATK4.
