#!/usr/bin/perl

#create bed files from samtools faidx output

use strict;
use warnings;

my $fai="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa.fai";

`cut -f1-2 $fai > chromo.size.bed`;

`bedtools makewindows -g chromo.size.bed -w 5000 -s 4850 -i srcwinnum> 5k_150bpOL_seg.bed`;

`rm chromo.size.bed`;


