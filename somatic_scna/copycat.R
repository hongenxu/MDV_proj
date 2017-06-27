#executed by ./run_copycat.pl



args<-commandArgs(trailingOnly=T)

normal_window<-args[1]
tumor_window<-args[2]
normal_vcf<-args[3]
tumor_vcf<-args[4]
output_dir<-args[5]

library(copyCat)

print(normal_window)

#see readme file in 'annotationDirectory' for details how to generated required files
runPairedSampleAnalysis(annotationDirectory="/home/proj/MDW_genomics/xu/scna/copycat_anno_galgal5/annotations/",
                    outputDirectory=output_dir,
                    normal=normal_window,
                    tumor=tumor_window,
                    inputType="bins",
                    maxCores=3,
                    binSize=0, #infer automatically from bam-window output
                    readLength=120,
                    perLibrary=1, #correct each library independently
                    perReadLength=0, #correct each read-length independently
                    verbose=TRUE,
                    minWidth=3, #minimum number of consecutive winds need to call CN
                    minMapability=0.6, #a good default
                    dumpBins=TRUE,
                    doGcCorrection=TRUE,
                    gcWindowSize=100,
                    samtoolsFileFormat="unknown", #will infer automatically - mpileup 10col or VCF
                    purity=1,
                    normalSamtoolsFile=normal_vcf,
                    tumorSamtoolsFile=tumor_vcf)




