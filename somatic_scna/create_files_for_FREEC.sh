#create  files needed for running control-FREEC

#running this script need a reference genome galgal5.fa,
#a SNP file Gallus_gallus.vcf


####create a directory of chromosomes for "chrFiles" parameter in "config_WGS.txt"


#input file for this part galgal5.fa

[ -d ./chromsomes ]  || mkdir ./chromosomes/


#faSplit was downloaded from UCSC kentutils
./faSplit byname galgal5.fa ./chromosomes/

#do not consider contigs not placed on chromsomes
rm ./chromosomes/NT*

for i in {1..28} 30 31 32 33 W Z LGE64 MT

do

    mv ./chromsomes/${i}.fa ./chromosomes/chr${i}.fa
    sed -i 's/>/>chr/g' ./chromosomes/chr${i}.fa

done

mv ./chromsomes/chrW.fa ./chromosomes/chrY.fa
mv ./chromsomes/chrZ.fa ./chromosomes/chrX.fa
sed -i 's/chrZ/chrX/g' ./chromosomes/chrX.fa
sed -i 's/chrW/chrY/g' ./chromosomes/chrY.fa



###create a file for "SNPfile" parameter in "config_WGS.txt"

#header line

#Gallus_gallus.vcf wad downloaded from http://ftp.ensembl.org/pub/release-86/variation/vcf/gallus_gallus/Gallus_gallus.vcf.gz
grep "#" Gallus_gallus.vcf >snp.vcf
#only consier SNV postions
grep -v "#" Gallus_gallus.vcf |grep "TSA=SNV" |awk '{print "chr"$0}'  >>snp.vcf

sed -i 's/chrW/chrY/g' snp.vcf
sed -i 's/chrZ/chrX/g' snp.vcf

##please note that if we use snp.vcf (include XY chromsomes) for samples with XX (ZZ) chromsomes, Control-FREEC will complain
##so when running control-FREEC for samples of XX, use snpXX.vcf instead
cp snp.vcf snpXX.vcf
sed -i '/chrY/d' snpXX.vcf

rm snpXX.vcf.gz 
gzip snpXX.vcf

rm snp.vcf.gz
gzip snp.vcf



############create a chromosome length file for "chrLenFile" paramter in "config_WGS.txt"

samtools faidx galgal5.fa
cp galgal5.fa.fai chr.tmp
sed -i '/NT/d' chr.tmp
awk 'BEGIN{i=0} i+=1 {print i"\t""chr"$1"\t"$2}' chr.tmp >chr.len

sed -i 's/chrW/chrY/g' chr.len
sed -i 's/chrZ/chrX/g' chr.len

##please note that if we use chr.len (include XY chromsomes) for samples with XX (ZZ) chromsomes, Control-FREEC will complain
##so when running control-FREEC for samples of XX, use chrXX.len instead
cp chr.len chrXX.len
sed -i '/chrY/d' chrXX.len


