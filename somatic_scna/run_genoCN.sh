#!/bin/bash


#working directory
wd="/home/proj/MDW_genomics/xu/microarray/"
cd ${wd}


#value="`cat germlinelistfile.forgenoCN`";
sample="`cat somaticlistfile`"

for i in ${sample}
    do 

        Rscript genoCN.R ${i}

    done


