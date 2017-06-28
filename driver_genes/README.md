
## Identify driver genes from mutations
Most of tools were designed specifically for human cancers or need external input only available for human.
We managed to use three tools of different strategies to identify driver genes.


1. MuSiC
  * Version:      version 0.0401
  * From:         http://gmt.genome.wustl.edu/packages/genome-music/index.html
  * Installation: see https://www.biostars.org/p/62793/ for dettails;
  * Usage:        see `merge_maf_files.sh` for details how to merge MAF files, the output file is required in `run_music.pl` ; for running MuSiC, see `run_music.pl` for details

2. oncodriveCLUST
  * Version:      version 1.0.0
  * From:         https://bitbucket.org/bbglab/oncodriveclust
  * Installation: pip install oncodriveclust
  * Usage:        see `run_oncodriveclust.pl` for details how to generate required input data, run, and extract potential driver genes

3. MUFFINN
  * Version:      version 1.0.0
  * From:         http://www.inetbio.org/muffinn/
  * Installation: /http://github.com/netbiolab/MUFFINN
  * Usage:        see the script for details for preparing files required running MUFFINN
