#!/bin/bash

#compare the results from copycat and control-freec 
#the comparision was for gain and loss separately
#the comparision was for each sample separately

#working directory
cd /home/proj/MDW_genomics/xu/scna/cmp_2tools/

##copy copycat and control-freec results
cp /home/proj/MDW_genomics/xu/scna/freec_results/results.freec.txt .
cp /home/proj/MDW_genomics/xu/scna/copycat_results/results.copycat.txt .

#join the results together 
awk '{print $0"\t""copycat"}' results.copycat.txt > tmp
awk '{print $0"\t""freec"}' results.freec.txt     >>tmp

#sort 
bedtools sort -i tmp >tmp.sorted.bed;

#split byCN type 
awk '{print $0>$4".txt"}' tmp.sorted.bed


rm tmp  tmp.bed tmp.sorted.bed

#split by sample 
awk '{print $0>"gain_"$5".txt"}' gain.txt
awk '{print $0>"loss_"$5".txt"}' loss.txt
awk '{print $0>"neutral_"$5".txt"}' neutral.txt


rm results.post.txt

sample=`cat samples` # samples was a file holds all samples (a sample a line)

for type in {"gain","loss","neutral"}

do
    for num in ${sample}
    do
        #echo ""
        if [ -f "${type}_${num}.txt" ];
        then
            echo ${type}_${num}.txt >>results.post.txt
            bedtools merge -i ${type}_${num}.txt -c 6 -o distinct |grep "," >>results.post.txt #see bedtools merge documentation

        else
            echo "file not exists"
        fi
    done
done


