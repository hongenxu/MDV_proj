#!/usr/bin/perl
#===============================================================================
#
#         FILE:  build_snpEff.pl
#
#        USAGE:  ./build_snpEff.pl
#
#  DESCRIPTION:  was used to build custom database Galgal5.00
#  				 see http://snpeff.sourceforge.net/SnpEff_manual.html#databases
#  				 #option 1: Building a database from GTF files
#
# REQUIREMENTS:  nc_vs_chrs.txt file
#        NOTES:  ---
#       AUTHOR:  Hongen XU (HX), hongen_xu@hotmail.com
#      COMPANY:  TUM
#      VERSION:  1.0
#      CREATED:  03/13/2016 07:12:42 PM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

my $input_dir="/home/proj/MDW_genomics/xu/galgal5";

###change ncbi accession number to ensemble (NC_XXXXXX to 1, 2 )
#see https://github.com/hongenxu/MDV_proj/blob/master/nc_vs_chrs.txt for details
open FILE, "nc_vs_chrs.txt" or die $!;
my %hash;
while (<FILE>){
	chomp;
	my ($ncbi,$ens)=split/\t/,$_;
	$hash{$ncbi}=$ens;
}
close FILE;

open GTF, "$input_dir/GCF_000002315.4_Gallus_gallus-5.0_genomic.gff" or die $!;
open OUT, ">genes_modified.gff" or die $!;
while (<GTF>){
	chomp;
	my ($acc,$a)=split(/\t/,$_,2);########pay attention to this type of usage of "split"

	if (exists $hash{$acc}){
		print OUT "$hash{$acc}\t$a\n";

	}
	else {
		print OUT "$_\n";
	}
}
close GTF;
close OUT;

#gffread from cufflinks
#change gff format to gtf format
system "gffread genes_modified.gff -T -o genes.gtf  -g $input_dir/galgal5.fa";
system "gzip -c genes.gtf >genes.gtf.gz";

#protein file not provieded in http://snpeff.sourceforge.net/SnpEff_manual.html#databases
system "cp $input_dir/GCF_000002315.4_Gallus_gallus-5.0_protein.faa protein.fa";

#genomic sequences
system "cp $input_dir/galgal5.fa ~/snpEff/data/Galgal5.00/sequences.fa";

###move these files to ~/snpEFF/data/Galgal5.00
system "mv genes.gtf genes.gtf.gz   ~/snpEff/data/Galgal5.00";

#submit the job to cluster
system "qsub -b y -q lofn-10g.q -N \"snpEff\" java -jar /home/users/xu/snpEff/snpEff.jar build -gtf22 -v Galgal5.00";
