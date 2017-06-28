#run MUFFINN

#require input data for MUFFINN, data4muffin.txt
wd="/home/proj/MDW_genomics/xu/driver_genes/muffinn/"
cd ${wd}

#muffinn directory 
muffinn="/home/users/xu/MUFFINN-1.0.0/MUFFINN/"

#copy data 
cp data4muffin.txt  ${muffinn}

cd ${muffinn}


#remove all files in the ouput directory before running MUFFINN
rm ${muffinn}/output/*

perl muffinn.pl data4muffin.txt

cd ${muffinn}/output/

head -n 101  DN* |grep -v "Rank" |grep -v "\=" |cut -f3|sort |uniq  -c  |sort > candidates

sed -i 's/^\s*//g' candidates

mv candidates ${wd}




