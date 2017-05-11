#create mappability file required for running Control-FREEC
# the input for this script is galgal5.fa
#gem library was downloaded from https://sourceforge.net/projects/gemlibrary/ (version 2013-04-06)

#to create a GEM index out of a FASTA file 
gem-indexer -i galgal5.fa -o galgal5 -T 4

#to compute the mappability of a reference 
gem-mappability -I ./galgal5.gem -l 120 -o galgal5.120mer -T 16

#change chromsome names, see comments in ./rename_mappability.pl
perl rename_mappability.pl

