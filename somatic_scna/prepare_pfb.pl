#!/usr/bin/perl

# create pfb file mdv.pfb using 8 samples mixed from 6 F1 controls

use strict;
use warnings;


#working directory
my $wd="/home/proj/MDW_genomics/xu/microarray/output";
chdir $wd;
#binary file folder for PennCNV
my $penncnv="/home/users/xu/PennCNV/";




my @keys=("D1","E2","A5","G6","H7","B8","F9","C11");

system "rm pfb_files.txt";

foreach my $key (@keys){
    `ls ./MDV.* |grep "\_$key\$" >> pfb_files.txt`;
}

`cat pfb_files.txt |sort |uniq >tmp.txt`;
`mv tmp.txt pfb_files.txt `;

system "perl $penncnv/compile_pfb.pl --listfile pfb_files.txt -output mdv.pfb";

`head -n 1 mdv.pfb >test`;
`sort -k 2,2 -k3,3n mdv.pfb > mdv.sorted.pfb`;
`sed -i '/^Name/d' mdv.sorted.pfb `;
`cat test ./mdv.sorted.pfb > mdv.pfb `;
`rm mdv.sorted.pfb`;

`sed -i 's/Z/X/g' mdv.pfb`; #change Z Chromosome to X





