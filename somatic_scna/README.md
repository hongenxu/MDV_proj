
### SCNAs

#### NGS data

1. Control-FREEC
* Version: 9.8b
* From: https://github.com/BoevaLab/FREEC/releases
* Notes: See [get_mappability_of_galgal5.sh](https://github.com/hongenxu/MDV_proj/blob/master/somatic_scna/get_mappability_of_galgal5.sh) and [rename_mappability.pl](https://github.com/hongenxu/MDV_proj/blob/master/somatic_scna/rename_mappability.pl) for details how to create mappability file used for Control-FREEC; See [create_files_for_FREEC.sh](https://github.com/hongenxu/MDV_proj/blob/master/somatic_scna/create_files_for_FREEC.sh) for details for generating files required by running Control-FREEC; config_WGS.txt was from Control-FREEC package

2. copyCat
* Version: 1.6.11
* From:  https://github.com/chrisamiller/copyCat
* Notes:
chicken GC and mappability files were created by following the [link](https://xfer.genome.wustl.edu/gxfer1/project/cancer-genomics/readDepth/createCustomAnnotations.v1.tar.gz);
copycat.R was executed by run_copycat.pl.

#### Microarray data

1. PennCNV-Affy
* Version: Not Available 
* From: http://www.openbioinformatics.org/penncnv/download/gw6.tar.gz
* Notes: only for preprocessing CEL data to LRR and BAF

2. PennCNV
* Version: 1.0.4
* From: https://github.com/WGLab/PennCNV/releases
* Notes: for creating Population Frequency of B allele (PFB) file using 8 F1 control birds

3. genoCN
* Version: 1.26.0
* From: https://www.bioconductor.org/packages/release/bioc/html/genoCN.html
* Notes:

4. ASCAT
* Version: 2.4.3
* From: https://github.com/Crick-CancerGenomics/ascat
* Notes: 
