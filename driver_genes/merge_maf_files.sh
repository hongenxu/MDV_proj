#!/bin/bash
set -e
set -u
set -o pipefail

#merge MAF files from 26 samples into a single file "myMAF.tsv"


wd="/home/proj/MDW_genomics/xu/driver_genes/"

cd ${wd}


#header 2 lines
head -n 2 /home/proj/MDW_genomics/xu/vep/maf/S1.maf >myMAF.tsv


for i in {1..26}

do
    #lines other than header
    grep -v "#" /home/proj/MDW_genomics/xu/vep/maf/S${i}.maf |grep -v "^Hugo"  >>myMAF.tsv
done


