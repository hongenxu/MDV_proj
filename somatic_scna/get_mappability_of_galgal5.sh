
wd="/home/proj/MDW_genomics/xu/scna/mappability/"

cd ${wd}

gem-indexer -i ../../galgal5/galgal5.fa -o galgal5 -T 4

gem-mappability -I ./galgal5.gem -l 120 -o galgal5.120mer -T 16

gem-2-wig -I galgal5.gem -i galgal5.120mer.mappability  -o mappability 


