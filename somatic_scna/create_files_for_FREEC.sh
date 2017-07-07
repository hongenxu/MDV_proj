#create  files needed for running control-FREEC

#running this script need a reference genome galgal5.fa,
#and a SNP file Gallus_gallus.vcf
#Gallus_gallus.vcf wad downloaded from http://ftp.ensembl.org/pub/release-86/variation/vcf/gallus_gallus/Gallus_gallus.vcf.gz
# require ucsc faSplit installed


ref="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
snp="/home/proj/MDW_genomics/xu/Gallus_gallus.vcf"
faSplit="/home/users/xu/bin/faSplit"

####create a directory of chromosomes for "chrFiles" parameter in "config_WGS.txt"
#input file for this part galgal5.fa


#working directory
wd="/home/proj/MDW_genomics/xu/scna/freec"
cd ${wd}


[ -d ./chromosomes ]  || mkdir ./chromosomes/ #create a directory


#faSplit was downloaded from UCSC kentutils
${faSplit} byname ${ref} ./chromosomes/

#do not consider contigs not placed on chromsomes
rm ./chromosomes/NT*

for i in {1..28} 30 31 32 33 W Z LGE64 MT

do

    mv ./chromosomes/${i}.fa ./chromosomes/chr${i}.fa  #rename file name
    sed -i 's/>/>chr/g' ./chromosomes/chr${i}.fa      #rename sequence name inside file

done

mv ./chromosomes/chrW.fa ./chromosomes/chrY.fa #rename file name
mv ./chromosomes/chrZ.fa ./chromosomes/chrX.fa #rename file name

sed -i 's/chrZ/chrX/g' ./chromosomes/chrX.fa  #rename sequence name inside file
sed -i 's/chrW/chrY/g' ./chromosomes/chrY.fa  #rename sequence name inside file



###create a file for "SNPfile" parameter in "config_WGS.txt"


#header line 
grep "#" ${snp} >snp.vcf
#only consier SNV postions
grep -v "#" ${snp} |grep "TSA=SNV" |awk '{print "chr"$0}'  >>snp.vcf

sed -i 's/chrW/chrY/g' snp.vcf
sed -i 's/chrZ/chrX/g' snp.vcf

##please note that if we use snp.vcf (include XY chromsomes) for samples with XX (ZZ) chromsomes, Control-FREEC will complain
##so when running control-FREEC for samples of XX, use snpXX.vcf instead
cp snp.vcf snpXX.vcf
sed -i '/chrY/d' snpXX.vcf #delete chrY

rm snpXX.vcf.gz 
gzip snpXX.vcf  #compress

rm snp.vcf.gz
gzip snp.vcf  #compress



###create a file used in "samtools mpileup", see 'run_control-freec.pl'

grep -v "#" ${ref} |grep "TSA=SNV" |grep -v "," |awk '{print "chr"$1"\t"$2-1"\t"$2}' >bedfile4Control-freec.bed



############create a chromosome length file for "chrLenFile" paramter in "config_WGS.txt"

samtools faidx ${ref}
cp ${ref}.fai chr.tmp
sed -i '/NT/d' chr.tmp  #delete contigs not placed on chromosomes
awk 'BEGIN{i=0} i+=1 {print i"\t""chr"$1"\t"$2}' chr.tmp >chr.len

sed -i 's/chrW/chrY/g' chr.len
sed -i 's/chrZ/chrX/g' chr.len

##please note that if we use chr.len (include XY chromsomes) for samples with XX (ZZ) chromsomes, Control-FREEC will complain
##so when running control-FREEC for samples of XX, use chrXX.len instead
cp chr.len chrXX.len
sed -i '/chrY/d' chrXX.len #delete chrY


