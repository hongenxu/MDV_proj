#!/usr/bin/perl

#USAGE:  perl rename_mappability.pl
#input file: ./galgal5.120mer.mappability
#output file: ./galgal5.120mer.renamed.mappability
#change chromosome name from 1,2,3... to chr1, chr2,chr3..., this format was required by Control-FREEC
#change chicken W chromsome to Y;
#change chicken Z chromsome to X; because Control-FREEC can only recognize XY

use strict;
use warnings;


open IN, "galgal5.120mer.mappability" or die $!;
open OUT, ">galgal5.120mer.renamed.mappability" or die $!;
while (<IN>){
	chomp;
	if ($_=~/^~(\d+)/){
		print OUT "~chr$1\n";
	}
	elsif ($_=~/^~([W|Z])/){
		my $join=join("","~","chr",$1);
		$join=~tr/WZ/YX/;
		print OUT "$join\n";
	}
	elsif($_=~/^~LGE64/){
		print OUT "~chrLGE64","\n";
	}
	else {
		print OUT "$_\n";
	}

}

close IN;
close OUT;
