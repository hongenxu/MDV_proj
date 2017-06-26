#!/bin/bash
set -e
set -u
set -o pipefail


#follow guidence at http://penncnv.openbioinformatics.org/en/latest/user-guide/affy/
#see recommendations for Axiom arrays in the guidence
#please download penncnv-affy and uncompile in the working directory
#please also download Affymetrix Power Tools (apt) version 1.19.0
#please download PennCNV


#####################you many need to change#####################

#working directory
wd="/home/proj/MDW_genomics/xu/microarray"
cd ${wd}

#directory for axiom; it includes files specific for this chip design
axiom_dir="/home/proj/MDW_genomics/xu/microarray/Axiom_67MDSNPs.r1"

#binary file folder for Affymetrix Power Tools
apt="/home/users/xu/apt_1.19.0/bin";

#binary file folder for penncnv-affy
affy="/home/proj/MDW_genomics/xu/microarray/gw6/bin"

#binary file folder for PennCNV
penncnv="/home/users/xu/PennCNV"

####################change end######################3

#affymetrxi power tools
${apt}/apt-probeset-genotype \
    --analysis-files-path ${axiom_dir} \
    --xml-file ${axiom_dir}/Axiom_67MDSNPs_96orMore_Step1.r1.apt-probeset-genotype.AxiomGT1.xml \
    --summaries \
    --out-dir  ${wd}/output \
    -cel-files ${wd}/cel_list.txt\
    --chrZ-probes ${axiom_dir}/Axiom_67MDSNPs.r1.chrZprobes \
    --chrW-probes ${axiom_dir}/Axiom_67MDSNPs.r1.chrWprobes


# preparing loc file used in the next step
grep -v "#" ${axiom_dir}/Axiom_67MDSNPs_Annotation.csv.r1.txt |cut -d"," -f1,4,5,8,9 >locfile.tmp
sed -i 's/"//g' locfile.tmp
sed -i 's/,/\t/g' locfile.tmp
awk '{print "chr"$2"\t"$3-1"\t"$3"\t"$1"\t"$4"/"$5}' locfile.tmp > locfile.galgal3
sed -i '/^chrSet/d' locfile.galgal3
liftOver locfile.galgal3 galGal3ToGalGal5.over.chain.gz locfile.galgal5 locfile.unmapped
awk '{print $4"\t"$1"\t"$3}' locfile.galgal5 > locfile.txt
sed -i 's/chr//g' locfile.txt
sed -i '/\_NT\_/d' locfile.txt



#penncnv-affy
perl ${affy}/generate_affy_geno_cluster.pl ${wd}/output/AxiomGT1.calls.txt \
                                            ${wd}/output/AxiomGT1.confidences.txt \
                                            ${wd}/output/AxiomGT1.summary.txt \
                                            --nopower2 --locfile ${wd}/locfile.txt  \
                                            --output ${wd}/output/batch1.genocluster\
                                            --sexfile ${wd}/sexfile.txt

perl ${affy}/normalize_affy_geno_cluster.pl ./output/batch1.genocluster \
                                              ./output/AxiomGT1.summary.txt \
                                            --nopower2 --locfile locfile.txt \
                                            --output ./output/batch1.lrr_baf.txt
cd ./output/

#penncnv
rm MDV.*
perl ${penncnv}/kcolumn.pl batch1.lrr_baf.txt split 2 -tab -head 3 -name -out MDV --beforestring .CEL



