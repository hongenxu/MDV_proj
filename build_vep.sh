#!/bin/bash
set -e
set -u
set -o pipefail

#used to build VEP database


#vep directory
cd ~/ensembl-tools-release-84/scripts/variant_effect_predictor
#copy GFF file to vep folder 
cp /home/proj/MDW_genomics/xu/snpEFF/genes_modified.gff   galgal5_genes.gff
#copy genome fasta file to vep folder
cp ~/snpEff/data/Galgal5.00/sequences.fa  galgal5_seq.fa
#run vep gtf2vep
perl gtf2vep.pl -i galgal5_genes.gff -f galgal5_seq.fa -d 84 -s gallus_gallus


