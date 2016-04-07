
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
  * Notes:     dbSNP VCF (Galgal5 version) was used, and see dbSNP_liftover step for details    
2. MuTect
  * Version:   MuTect-1.1.7, built from source
  * From:      https://github.com/broadinstitute/mutect
  * Usage: 
 ```
     java -jar mutect-1.1.7.jar --analysis_type MuTect  --reference_sequence genome --input_file:tumor tumor_bam --input_file:normal normal_bam --out  output_dir/sample.classical.out --coverage_file output_dir/sample.cov.out --vcf output_dir/sample.vcf
 ```
  * Filtering: No
  * Notes:     No
3. MuTect2
  * Version:   MuTect2 is inclued in GATK (version 3.5 and above), GATK version 3.5 was used
  * From:      https://www.broadinstitute.org/gatk/download/
  * Usage: 
 ```
     java -jar GenomeAnalysisTK.jar --analysis_type MuTect2  --reference_sequence genome --input_file:tumor tumor_bam --input_file:normal normal_bam --out  output_dir/sample.vcf
 ```
  * Filtering: No
  * Notes:     Not included in SomaticSeq analysis
4. JointSNVMix2
  * Version:   Version 0.7.5
  * From:      https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/joint-snv-mix/JointSNVMix-0.7.5.tar.gz
  * Usage: 
 ```
    jsm.py train joint_snv_mix_two --min_normal_depth 8 --min_tumour_depth 6 genome.fa normal.bam tumor.bam config/joint_priors.cfg config/joint_params.cfg sample.cfg
     jsm.py classify joint_snv_mix_two genome.fa normal.bam tumor.bam sample.cfg sample.tsv
 ```
  * Filtering: 
 ```
     awk -F "\t" 'NR!=1 && $4!="N" && $10+$11>=0.95' sample.tsv >sample.filtered.tsv
 ```
  * Notes:     For sample S5, I repeatedly got the error messages “Exception: Lower bound decreased exiting”. Based on the recommendations here (https://code.google.com/archive/p/joint-snv-mix/issues/8), I set the --convergence_threshold flag when training to a value above the default of 0.000001 to 0.01 for sample S5
5. SomaticSniper
  * Version:   V1.0.5.0, from release
  * From:      https://github.com/genome/somatic-sniper
  * Usage:
 ```
     bam-somaticsniper -q 1 -Q 20 -s 0.01 -F vcf -f reference_genome tumor_bam normal_bam out.vcf
 ```
  * Filtering: Basic filtering scripts were provided, but filtering was not used in SomaticSeq, so I decided not to use the filtering.
  * Notes:     No
6. VarDict
  * Version:   No version information available
  * From:      https://github.com/AstraZeneca-NGS/VarDict (original perl version of VarDict) & https://github.com/AstraZeneca-NGS/VarDictJava (replacement java version, 10X fast)
  * Usage:
 ```
     VarDict -G genome -b "tumor_bam|normal_bam" -th 1 –F 0x500 –z -C -c 1 -S 2 -E 3 -g 4 5k_150bpOL_seg.bed  > out.vardict 
     cat our.vardict | testsomatic.R | var2vcf_paired.pl –f 0.01
 ```
  * Filtering: steps 2 & 3 above can be seen as filtering
  * Notes:     (1) https://github.com/AstraZeneca-NGS/VarDict/issues/2 explains why VarDict needs input bed files and Bed regions are recommended to have 150 bp overlap for WGS data to call indels; (2) to speed up, split 5k_150bpOL_seg.bed into several files; (3)var2vcf_paired.pl was used since the author of VarDict recommended (see SomaticSeq manual)
7. VarScan2
  * Version:   VarScan.v2.4.1.jar
  * From:      https://github.com/dkoboldt/varscan
  * Usage: 
 ```
     samtools mpileup -f genome.fa -q 20 -B normal.bam tumor.bam >normal.tumor.fifo
     java -jar VarScan.jar somatic normal.tumor.fifo --mpileup 1 --output-vcf --output-snp output.snp.vcf --output-indel output.indel.vcf
 ```
  * Filtering:
 ```
     java -jar VarScan.jar processSomatic output.indel.vcf
     java -jar VarScan.jar processSomatic outputsnp.vcf
 ```
  * Notes:     (1) See http://dkoboldt.github.io/varscan/ for usage. (2) see https://www.biostars.org/p/123430/ for "NOT RESETTING NORMAL error using Varscan2" (3) Call varScan using named pipes (fifos) instead of anonymous pipe See https://gist.github.com/seandavi/1022747 for details. Also used in SomaticSeq “Run_5_callers”
8. SomaticSeq

###Indels
1.  MuTect2
  
 See SNVs section for details, and not used in SomaticSeq analysis.
2.  Indelocator
  * Version: IndelGenotyper.36.3336
  * From:    https://www.broadinstitute.org/cancer/cga/indelocator_download
  * Usage:
  ```
 java -jar IndelGenotyper.jar --analysis_type IndelGenotyperV2 --somatic --reference_sequence genome.fa --input_file:tumor Tumor.bam  --input_file:normal Normal.bam --out out.vcf
 ```
  * Filtering:No
  * Notes:    No
3.  VarDict
  
 See SNVs section for details.
4.  VarScan2
 
 See SNVs section for details.

