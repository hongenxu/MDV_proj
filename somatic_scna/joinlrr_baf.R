library(plyr)
setwd("/home/proj/MDW_genomics/xu/microarray/lrr_baf/")

####join normal BAF values

normal<-read.table("../normallistfile")
samples<-as.character(normal$V1)


list8 <- list()
i<-0
for (sample in samples){
    i<-i+1
    print(i)
    print(sample)
    baffile<-paste(sample,".BAF",sep="")
    data<-read.table(baffile,header = FALSE,col.names=c("snp","chr","pos",sample))
    list8[[i]]<-data
}

ndf<-join_all(list8,by=c("snp","chr","pos"),type = "full") 
colnames(ndf)<-c("snp","chr","pos",samples)

avg<-c()
for (i in 1:length(ndf$pos)){
    avg[i]<-mean(as.numeric(ndf[i,c(-1,-2,-3)]))
}
ndf[,c(4:75)]<-""

for (j in 4:75){
     ndf[,j]<-avg
}

write.table(ndf, file = "Normal_BAF.txt", quote = F, sep = "\t",row.names = F, col.names = T)



############join tumor BAF values 
somatic<-read.table("../somaticlistfile")
samples<-as.character(somatic$V1)

list72 <- list()
i<-0
for (sample in samples){
    i<-i+1
    print(i)
    print(sample)
    baffile<-paste(sample,".BAF",sep="")
    data<-read.table(baffile,header = FALSE,col.names=c("snp","chr","pos",sample))
    list72[[i]]<-data
}



ndf<-join_all(list72,by=c("snp","chr","pos"),type = "full") 
colnames(ndf)<-c("snp","chr","pos",samples)

write.table(ndf, file = "Tumor_BAF.txt", quote = F, sep = "\t",row.names = F, col.names = T)



#######join normal LRR values 
normal<-read.table("../normallistfile")
samples<-as.character(normal$V1)


list8 <- list()
i<-0
for (sample in samples){
    i<-i+1
    print(i)
    print(sample)
    lrrfile<-paste(sample,".LRR",sep="")
    data<-read.table(lrrfile,header = FALSE,col.names=c("snp","chr","pos",sample))
    
    list8[[i]]<-data
}


ndf<-join_all(list8,by=c("snp","chr","pos"),type = "full") 
colnames(ndf)<-c("snp","chr","pos",samples)

avg<-c()
for (i in 1:length(ndf$pos)){
    avg[i]<-mean(as.numeric(ndf[i,c(-1,-2,-3)]))
}
ndf[,c(4:75)]<-""

for (j in 4:75){
     ndf[,j]<-avg
}

write.table(ndf, file = "Normal_LRR.txt", quote = F, sep = "\t",row.names = F, col.names = T)



#########join tumor LRR values 


somatic<-read.table("../somaticlistfile")
samples<-as.character(somatic$V1)



list72 <- list()
i<-0
for (sample in samples){
    i<-i+1
    print(i)
    print(sample)
    lrrfile<-paste(sample,".LRR",sep="")
    data<-read.table(lrrfile,header = FALSE,col.names=c("snp","chr","pos",sample))
    list72[[i]]<-data
}



ndf<-join_all(list72,by=c("snp","chr","pos"),type = "full") 
colnames(ndf)<-c("snp","chr","pos",samples)

write.table(ndf, file = "Tumor_LRR.txt", quote = F, sep = "\t",row.names = F, col.names = T)



