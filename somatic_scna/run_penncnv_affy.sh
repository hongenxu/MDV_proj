#follow guidence at http://penncnv.openbioinformatics.org/en/latest/user-guide/affy/
#see recommendations for Axiom arrays


dir="/scratch/xu/MDV_project/microarray/Axiom_67MDSNPs.r1"


~/apt_1.19.0/bin/apt-probeset-genotype \
    --analysis-files-path ${dir} \
    --xml-file ${dir}/Axiom_67MDSNPs_96orMore_Step1.r1.apt-probeset-genotype.AxiomGT1.xml \
    --summaries \
    --out-dir  /scratch/xu/MDV_project/microarray/output \
    -cel-files /scratch/xu/MDV_project/microarray/cel_list.txt\
    --chrZ-probes ${wd}/Axiom_67MDSNPs.r1.chrZprobes \
    --chrW-probes ${wd}/Axiom_67MDSNPs.r1.chrWprobes



# preparing loc file
grep -v "#" ./Axiom_67MDSNPs.r1/Axiom_67MDSNPs_Annotation.csv.r1.txt |cut -d"," -f1,4,5 >locfile.txt
sed -i 's/"//g' locfile.txt
sed -i 's/,/\t/g' locfile.txt


perl ./gw6/bin/generate_affy_geno_cluster.pl ./output/AxiomGT1.calls.txt \
                                            ./output/AxiomGT1.confidences.txt \
                                            ./output/AxiomGT1.summary.txt \
                                            --nopower2 --locfile locfile.txt  \
                                            --output ./output/batch1.genocluster\
                                            --sexfile sexfile.txt

perl ./gw6/bin/normalize_affy_geno_cluster.pl ./output/batch1.genocluster \
                                              ./output/AxiomGT1.summary.txt \
                                            --nopower2 --locfile locfile.txt \
                                            --output ./output/batch1.lrr_baf.txt
cd ./output/

perl ~/PennCNV/kcolumn.pl batch1.lrr_baf.txt split 2 -tab -head 3 -name -out MDV --beforestring .CEL



