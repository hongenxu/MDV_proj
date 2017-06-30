#!/usr/bin/perl

use strict;
use warnings;


my @samples=("017733","017738-1","017741-1","017748","017756-3","017766-1","017777-3","017787-2","017794-1","017798-1_1","017798-1_2","017820","017824","017833-1","017834-2","017835-1","017841-3","017842-2_1","017842-2_2","017855-1_1","017855-1_2","017863-1","017884-2","017901-2_1","017901-2_2","017906-1","017911-1_1","017911-1_2","017918-3","017927-2","017936","017939","017945","017947");


###a total of 34 samples

foreach my $i (1..34){
    $i--;
    my $sample=$samples[$i];
    print "$sample\n";
    system "cp qsub.sub $sample.sub";
    system "perl /mnt/home/hongenxu/RNAseq/rnaseq.pl --sample $sample >>$sample.sub";
    system "echo 'qstat -f \$\{PBS_JOBID\}' >> $sample.sub";
    #system "qsub $sample.sub";

}

