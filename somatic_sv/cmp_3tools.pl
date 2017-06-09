#!//usr/bin/perl


use strict;
use warnings;

my @types=("DEL","INV","ITX","INS");
#my @types=("INS");

system "rm all.bed && touch all.bed";
foreach my $i (1..26){
    my $sample=join("","S",$i);
    foreach my $type (@types){
        open OUT, ">tmp" or die $!;
        foreach my $tool ("breakdancer","delly","novobreak"){
            my $result=join("","./","$tool","_results","/",$tool,".bed");
            print "$sample\t$type\n";
            open FILE, "$result" or die $!;
            while (<FILE>){
                chomp;
                my ($chr1,$start1,$end1,$chr2,$start2,$end,$nsample,$ntype)=split/\t/,$_;
                if ($nsample eq $sample and $ntype eq $type and abs($start1-$end1)<1000000){
                     print OUT "$chr1\t$start1\t$end1\t$sample\t$type\t","$tool\n" if $end1>$start1;
                     print OUT "$chr1\t$end1\t$start1\t$sample\t$type\t","$tool\n" if $start1>$end1;
                }

            }
            close FILE;

        }
        close OUT;
        my $count=`cat tmp |wc -l`;
        chomp $count;
        if ($count>0){
            `bedtools sort -i tmp >tmp.sorted.bed`;
            `bedtools merge -i tmp.sorted.bed -c 4,5,6 -o distinct,distinct,distinct >>all.bed`;
        }

    }
}


close OUT;


