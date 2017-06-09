#!//usr/bin/perl
#summarize results from novobreak

use strict;
use warnings;

my $wd="/home/proj/MDW_genomics/xu/SVs/novobreak_results/";
chdir $wd;

open OUT, ">novobreak.bed" or die $!;
foreach my $i (1..26){
    my $file=join(".","S$i","vcf");
    if (-e $file ){
        open  FILE,"$file" or die $!;
        while (<FILE>){
            chomp;
            next if $_=~/^#/;
            my @lines=split/\t/,$_;
		        my $chr1=$lines[0];
		        my $start1=$lines[1];
		        $lines[4]=~/\<(.*)\>/;
                my $type=$1;
		        my $info=$lines[7];
		        my @infos=split/\;/,$info;
                my $chr2=$infos[7];
                my $start2=$infos[8];
                $chr2=~s/CHR2=//g;
                $start2=~s/END=//g;

                if ($type eq "TRA"){ #rename "TRA" to "ITX" or "CTX" for the sake of consistence
                    if ($chr1 eq $chr2){
                        $type="ITX";
                        $start1--;
                        print OUT "$chr1\t$start1\t$start2\t",".\t.\t.\t","S$i\t$type\n";
                    }
                    else {
                        $type="CTX";
                        print OUT "$chr1\t$start1\t$start1\t$chr2\t$start2\t$start2\t","S$i\t$type\n";                        }
                }

                else{
                    $type="INS" if $type eq "DUP"; #rename "DUP" to "INS"
                    $start1--;
                    print OUT "$chr1\t$start1\t$start2\t",".\t.\t.\t","S$i\t","$type\n";
                }
        }
            close FILE;
    }

}


close OUT;

