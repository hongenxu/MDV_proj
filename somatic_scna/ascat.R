library("RColorBrewer")
library("ASCAT")



setwd("/home/proj/MDW_genomics/xu/microarray")
sex<-read.table("somatic.sex")

setwd("./lrr_baf")
ascat.bc = ascat.loadData("Tumor_LRR.txt","Tumor_BAF.txt",
                          "Normal_LRR.txt","Normal_BAF.txt",
                          gender = sex$V2,chrs=c(1:28))

setwd("../ascat_results")
ascat.plotRawData(ascat.bc)
ascat.gg = ascat.predictGermlineGenotypes(ascat.bc) 
ascat.bc = ascat.aspcf(ascat.bc,ascat.gg=ascat.gg) 

ascat.plotSegmentedData(ascat.bc)
ascat.output = ascat.runAscat(ascat.bc) 



