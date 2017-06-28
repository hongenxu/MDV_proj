#!/usr/bin/perl

use strict;
use warnings;


#prepare data used for 'oncodriveclust'
#run the 'oncodriveclust' tool to identify potential driver genes

my $wd="/home/proj/MDW_genomics/xu/driver_genes/";
chdir $wd;
my $output_dir="/home/proj/MDW_genomics/xu/driver_genes/oncodriveclust_results/";



my %p_hash;

open MAF, "myMAF.tsv" or die $!;
open OUT1, ">$output_dir/nonsyn.txt" or die $!; #keep non-synonymous mutations
open OUT2, ">$output_dir/syn.txt" or die $!;    #keep synonymous mutations
open OUT3, ">$output_dir/gene_transcript.tsv" or die $!;#keep information about transcript and CDS length

print OUT1 "symbol\tgene\ttranscript\tSample\tct\tposition\n";#ct means "change type" of mutations
print OUT2 "symbol\tgene\ttranscript\tSample\tct\tposition\n";
print OUT3 "symbol\ttranscript\tCDS_length\n";

while (<MAF>){
    chomp;
    next if $_=~/^\#/;
    my @fields=split/\t/,$_;
    my $symbol=$fields[0];
    my $var_class=$fields[8];
    my $ref=$fields[10];
    my $alt="$fields[12]";
    my $tumor=$fields[15];
    my $gene=$fields[47];
    my $transcriptID=$fields[37];
    my $cds_pos=$fields[52];
    my ($pos,$length)=split/\//,$cds_pos;
    if ($var_class eq "Silent"){
        print OUT2 "$symbol\t$gene\t$transcriptID\t$tumor\t","synonymous\t$pos\n";
        print OUT3 "$symbol\t$transcriptID\t$length\n";
    }
    if ($var_class eq "Missense_Mutation" or $var_class eq "Nonsense_Mutation"){
        print OUT1 "$symbol\t$gene\t$transcriptID\t$tumor\t","non-synonymous\t$pos\n" if $var_class eq "Missense_Mutation";
        print OUT1 "$symbol\t$gene\t$transcriptID\t$tumor\t","stop\t$pos\n" if $var_class eq "Nonsense_Mutation";
        print OUT3 "$symbol\t$transcriptID\t$length\n";
    }


}

close MAF;
close OUT1;
close OUT2;
close OUT3;



#remove redundant lines in 'gene_transcript' file
system "head -n 1 $output_dir/gene_transcript.tsv >$output_dir/tmp"; #header line
system "grep -v '^symbol' $output_dir/gene_transcript.tsv |sort |uniq >> $output_dir/tmp"; #lines other than header
system "mv $output_dir/tmp $output_dir/gene_transcript.tsv";


#run oncodriveclust
chdir "$output_dir";
system "oncodriveclust -m 1  nonsyn.txt syn.txt gene_transcript.tsv";
chdir "$wd";

#extract driver genes and print
open RESULTS,"$output_dir/oncodriveclust-results.tsv" or die $!;
while (<RESULTS>){
    chomp;
    next if $_=~/^GENE/;
    my @fields=split/\t/,$_;
    my $gene=$fields[0];
    my $qvalue=$fields[9];
    if ( $qvalue ne "NA" and $qvalue<0.05){
        print "$gene\n";

    }

}
close RESULTS;

