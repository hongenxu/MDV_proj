#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  make_galgal5_reference.pl
#
#        USAGE:  ./make_galgal5_reference.pl  
#
#  DESCRIPTION: used to create the galgal5 reference genome, the fasta sequence dictionary file, and the fasta index file 
#               see http://gatkforums.broadinstitute.org/gatk/discussion/1601/how-can-i-prepare-a-fasta-file-to-use-as-reference
# REQUIREMENTS:  ---
#        NOTES:  ---
#       AUTHOR:  Hongen XU (HX), hongen_xu@hotmail.com
#      COMPANY:  TUM
#      VERSION:  1.0
#      CREATED:  02/22/2016 07:11:38 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use File::Temp qw(tempdir);

#download file 
system "wget ftp://ftp.ncbi.nih.gov/genomes/refseq/vertebrate_other/Gallus_gallus/latest_assembly_versions/GCF_000002315.4_Gallus_gallus-5.0/GCF_000002315.4_Gallus_gallus-5.0_genomic.fna.gz";

###rename chromosome names from NC*** to 1, 2, 3 .... 
###keep unplaced contigs as NT****
open SEQ, "GCF_000002315.4_Gallus_gallus-5.0_genomic.fna" or die $!;
my $tmp_dir=tempdir(CLEANUP=>0);#keep the temp file folder for investigation 

print "tmp dir $tmp_dir\n";
while (<SEQ>){
	chomp;
	if ($_=~/^>/){#sequence name lines 
		my $chr;
		if ($_=~/^>NC/){#for chromosomes 1, 2, 3 
			$chr=$1 if $_=~/chromosome\s{1}(\w+)/;
			$chr="MT" if $_=~/mitochondrion/; ###for MT
			$chr="LGE64" if $_=~/LGE64/; ###for LGE64
			open OUT, ">$tmp_dir/$chr.fa" or die $!;
			print OUT ">$chr\n";
			print "Processing $chr\n";
		}
		else {#for unplaced contigs 
			my @eles=split/\s{1}/,$_;
			my $contig=$eles[0];	
			open OUT, ">>$tmp_dir/unknown.fa";
			print OUT "$contig\n";
			print "Processing $contig\n";
		}
	}
	else {#sequence lines 
		$_=~tr/atcg/ATCG/; #lowcase to capital
		print OUT "$_\n";
	}
}
close OUT;
close SEQ;




####sort by chromosome number
system "rm galgal5.fa";
foreach my $chr (1..28,30,31,32,33,"W","Z","LGE64","MT"){
	system "cat $tmp_dir/$chr.fa >> galgal5.fa";
}
system "cat $tmp_dir/unknown.fa >>galgal5.fa";

system "rm $tmp_dir -r";

#index galgal5 and creat dictionary file 
system "~/bwa/bwa index galgal5.fa";
system "rm galgal5.dict";
system "java -jar  ~/picard-tools-1.141/picard.jar CreateSequenceDictionary R=galgal5.fa O=galgal5.dict";
system "samtools faidx galgal5.fa";


