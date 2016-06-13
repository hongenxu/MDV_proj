
## Calling SNVs and Indels from RNAseq data
This pipeline was used to call SNVs and Indels from RNAseq data, and it's not simply follow GATK best practics
and also considered RECOMMENDATIONS in STAR manual.

###SNVs
1. MuSE
  * Version:   MuSEv1.0rc_c039ffa
  * From:      http://bioinformatics.mdanderson.org/main/MuSE#Download
  * Usage:
  ```
     MuSE call –O Output.Prefix –f Reference.Genome Tumor.bam Matched.Normal.bam 
     MuSE sump -I Output.Prefix.MuSE.txt -G –O Output.Prefix.vcf –D dbsnp.vcf.gz
 ```
  * Filtering: No
