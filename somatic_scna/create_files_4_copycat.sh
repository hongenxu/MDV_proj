
wd="/home/proj/MDW_genomics/xu/scna/copycat_anno_galgal5/annotations/"
cd ${wd}

################################create gaps.bed file 

#require bedtools installed
#ucsc_gaps.bed was downloaded from UCSC table browser, galgal5

grep -v "#" ucsc_gaps.bed |cut -f2-4,8 >tmp
sed -i '/_/d' tmp
sed -i 's/chr//g' tmp
bedtools sort -i tmp >gaps.bed
rm tmp

#############################create entrypoints.female and entrypoints.male file
#create manually
#the first column is chromosome;
#the second one is length of this chromosome
#the third one is the number of this chromosme in female or male
#see $wd for my files


##################create gc and mappability files
#see /home/proj/MDW_genomics/xu/scna/copycat_anno_galgal5/createCustomAnnotations.v1/ for details
#downloaded from https://xfer.genome.wustl.edu/gxfer1/project/cancer-genomics/readDepth/createCustomAnnotations.v1.tar.gz

