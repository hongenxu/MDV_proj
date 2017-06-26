library(genoCN)
library(plyr)
library(gdata)

setwd("/home/proj/MDW_genomics/xu/microarray/")

args <- commandArgs(trailingOnly = TRUE)
sample<-args[1]



###for pfb file 
snpInfo<-read.table("./output/mdv.pfb",header=T)
snpInfo<-snpInfo[snpInfo$Chr!="UNK",] #remove SNPs on unknown chromosomes
snpInfo<-snpInfo[snpInfo$Chr!="16",] #only 3 markers on chromosome 16
snpInfo <- drop.levels(snpInfo)
snpInfo <- snpInfo[order(snpInfo$Chr),]
snpInfo$Name<-as.character(snpInfo$Name)
snpInfo$Chr<-as.character(snpInfo$Chr)


#for LRR file and BAF file
lrrfile<-paste("./lrr_baf/",sample,".LRR",sep="")
baffile<-paste("./lrr_baf/",sample,".BAF",sep="")
lrr<-read.table(lrrfile)
baf<-read.table(baffile)


#join LRR and BAF
data<-join_all(list(lrr,baf),by=c("V1","V2","V3"),type = "inner") 
data <- data[order(data$V2),]
data<-data[data$V2!="UNK",]
data<-data[data$V2!="16",]#only 3 markers on chromosome 16
data <- drop.levels(data)

snpData<-data[,c(1,4,5)]

colnames(snpData)<-c("Name","LRR","BAF")

snpData$Name<-as.character(snpData$Name)



#Theta = genoCNV(snpInfo$Name, snpInfo$Chr, snpInfo$Position, snpData$LRR, snpData$BAF,
#                snpInfo$PFB, sampleID=sample, cnv.only=(snpInfo$PFB>1), outputSeg = TRUE,
#                outputSNP = 2, outputTag =sample,loh=TRUE, output.loh=TRUE)

#function from R library genoCN

setwd("./genoCN_results/")
Theta = genoCNA(snpInfo$Name, snpInfo$Chr, snpInfo$Position, snpData$LRR, snpData$BAF,
                snpInfo$PFB, sampleID=sample, cnv.only=(snpInfo$PFB>1), outputSeg = TRUE,
                outputSNP = 2, outputTag =sample)




