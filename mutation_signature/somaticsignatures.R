
#working directory
setwd("/home/proj/MDW_genomics/xu/mut_signature")

#required input data
#a reference genome fasta file 
#and a mutation file 
galgal5=FaFile("/home/proj/MDW_genomics/xu/galgal5/galgal5.fa")
mut<-read.table("./mutations.vcf",header=F)


#required libraries
library(SomaticSignatures)
library(SomaticCancerAlterations)
library(ggplot2)
library(VariantAnnotation)
library(BSgenome.Hsapiens.1000genomes.hs37d5)

###SomaticCancerAlterations package provides the somatic SNV calls for eight WES studies, 
###each investigating a different cancer type.
sca_data = unlist(scaLoadDatasets())

sca_data$study = factor(gsub("(.*)_(.*)", "\\1", toupper(names(sca_data))))
sca_data = unname(subset(sca_data, Variant_Type %in% "SNP"))
sca_data = keepSeqlevels(sca_data, hsAutosomes(),pruning.mode="coarse")

sca_vr = VRanges(
  seqnames = seqnames(sca_data),
  ranges = ranges(sca_data),
  ref = sca_data$Reference_Allele,
  alt = sca_data$Tumor_Seq_Allele2,
  sampleNames = sca_data$Patient_ID,
  seqinfo = seqinfo(sca_data),
  study = sca_data$study)


##our MDV project data 


mdv_vr = VRanges(
            seqnames =mut$V1,
            ranges = IRanges(start = mut$V2, width = 1),
            ref = mut$V4,
            alt = mut$V5,
            sampleNames=mut$V12,
            study=mut$V13)

####mutation context 

sca_motifs = mutationContext(sca_vr,BSgenome.Hsapiens.1000genomes.hs37d5)
mdv_motifs = mutationContext(mdv_vr,galgal5)

motifs=c(mdv_motifs,sca_motifs)

####motif matrix
mm = motifMatrix(motifs, group = "study", normalize = TRUE)


#Mutation spectrum
p1<-plotMutationSpectrum(motifs,"study")


###number of signatures,test from 2 to 8, and choose an optimal value (i.e., 5)
n_sigs = 2:8
gof_nmf = assessNumberSignatures(mm, n_sigs, nReplicates = 5)
gof_pca = assessNumberSignatures(mm, n_sigs, pcaDecomposition)

p2<-plotNumberSignatures(gof_nmf)
p3<-plotNumberSignatures(gof_pca)

n_sigs = 5
sigs_nmf = identifySignatures(mm, n_sigs, nmfDecomposition)
sigs_pca = identifySignatures(mm, n_sigs, pcaDecomposition)


#Visualization: Exploration of Signatures and Samples

p4<-plotSignatureMap(sigs_nmf) + ggtitle("Somatic Signatures: NMF - Heatmap")
p5<-plotSignatures(sigs_nmf) + ggtitle("Somatic Signatures: NMF - Barchart")
p6<-plotObservedSpectrum(sigs_nmf)
p7<-plotFittedSpectrum(sigs_nmf)
p8<-plotSampleMap(sigs_nmf)
p9<-plotSamples(sigs_nmf,normalize = T)

p10<-plotSignatureMap(sigs_pca) + ggtitle("Somatic Signatures: PCA - Heatmap")
p11<-plotSignatures(sigs_pca) + ggtitle("Somatic Signatures: PCA - Barchart")
p12<-plotFittedSpectrum(sigs_pca)
p13<-plotObservedSpectrum(sigs_pca)

plots<-c("p1","p2","p3","p4","p5","p6","p7","p8","p9","p10","p11","p12","p13")
l<-mget(plots)


#save plot to a file 
pdf("signatures.pdf")
invisible(lapply(l, print))
dev.off()



