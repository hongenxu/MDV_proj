#!/usr/bin/perl


use strict;
use warnings;

#prepare file required for running MUFFINN  http://www.inetbio.org/muffinn/
#read answers for my question about how to make MUFFINN applied to chicken genome on github
#https://github.com/netbiolab/MUFFINN/issues/1#issuecomment-242611109

#Orthologs clusters for Homo sapiens and Gallus gallus were downloaded from inparanoid 8

#specifically, 'G.Gallus-H.sapiens.orthoXML' file was from
#http://inparanoid.sbc.su.se/download/8.0_current/Orthologs_OrthoXML/G.gallus/G.gallus-H.sapiens.orthoXML
#'sqltable.G.gallus-H.sapiens' was from
#http://inparanoid.sbc.su.se/download/8.0_current/Orthologs_other_formats/G.gallus/InParanoid.G.gallus-H.sapiens.tgz
#"hgnc_complete_set.txt" file was  from
#ftp://ftp.ebi.ac.uk/pub/databases/genenames/new/tsv/hgnc_complete_set.txt on september 1 of 2016


#working directory
my $wd="/home/proj/MDW_genomics/xu/driver_genes/muffinn/";
chdir $wd;
my $maf="/home/proj/MDW_genomics/xu/driver_genes/myMAF.tsv";



open SQL, "sqltable.G.gallus-H.sapiens" or die $!;
#example of sqltable
#1   12888 G.gallus 1.000 F1NG02 100%
#1   12888 H.sapiens 1.000 Q8NF9 1100%
#2   9873 G.gallus 1.000 F1NRP8 100%
#2   9873 H.sapiens 1.000 Q03001 100%


#count the number of occurrence of cluster, select cluster with 2 occurrence (G.gallus and H.sapiens)
#pair cluster id and proteinID(for example F1NG02)
my %count;
my %proteinID;

while (<SQL>){
    chomp;
    my ($cluster,$geneID,$species,$a,$proteinID,$b)=split/\t/,$_;
    if (exists $count{$cluster}){
        $count{$cluster}++;
    }
    else {
        $count{$cluster}=1;
    }
    if (exists $proteinID{$cluster}){
        $proteinID{$cluster}=join(";",$proteinID{$cluster},$proteinID);
    }
    else {
        $proteinID{$cluster}=$proteinID;

    }
}
close SQL;

#pair ProteinID and geneID
my %hash;
open XML, "G.gallus-H.sapiens.orthoXML" or die $!;
while (<XML>){
    chomp;
    if ($_=~/^\s+\<gene id/){
        $_=~/protId\=\"(.*)\" geneId\=\"(.*)\"/;
        my $proteinID=$1;
        my $geneId=$2;
        $hash{$proteinID}=$geneId;
    }
}
close XML;


`cut -f2,19 hgnc_complete_set.txt >entrez_hgnc.txt`;
my %entrez_hgnc;
#pair hgnc gene name to entrez gene id
open EH, "entrez_hgnc.txt" or die $!;
while (<EH>){
    chomp;
    next if $_=~/^\#/;
    my ($hgnc,$entrez)=split/\t/,$_;
    $entrez_hgnc{$hgnc}=$entrez;

}

close EH;


my %pairs;
#pair chicken geneID and human entrez geneID
open OUT, ">pairs.txt" or die $!;
foreach my $key ( sort {$a<=>$b} keys %count) {
    if ($count{$key}==2){ #only consier 1:1 Orthologs clusters
        my ($chicken_proteinID,$human_proteinID)=split/\;/,$proteinID{$key};#first is chicken proteinID and the second is human proteinID
        my $human_geneID=$hash{$human_proteinID};
        my $chicken_geneID=$hash{$chicken_proteinID};
        if (exists $entrez_hgnc{$human_geneID}){
            print OUT "$chicken_geneID\t$chicken_proteinID\t$human_geneID\t$human_proteinID\t$entrez_hgnc{$human_geneID}\n";
            $pairs{$chicken_geneID}=$entrez_hgnc{$human_geneID};
            $pairs{$human_geneID}=$entrez_hgnc{$human_geneID};
        }
    }
}

close OUT;



#prepare 'mutation.data', extract Hugo_Symbol and Variant_Classification from maf file

`cat $maf |grep -v "^#" |grep -v "^Hugo" | cut -f1,9 >mutation.data  `;

#count the number of mutations for each gene
my %mut;
open MUTATION, "mutation.data" or die $!;
while (<MUTATION>){
    chomp;
    my ($cgnc,$type)=split/\t/,$_;

    if (exists $mut{$cgnc}){
         if ($type eq "Translation_Start_Site" or $type eq "Frame_Shift_Del" or $type eq "Frame_Shift_Ins" or $type eq "In_Frame_Ins" or $type eq "In_Frame_Del" or $type eq "Missense_Mutation" or $type eq "Nonstop_Mutation" or $type eq "Nonsense_Mutation" or $type eq "Splice_Site"){
            $mut{$cgnc}++;
        }
        else {
        #do nothing
        }
    }
    else {
         if ($type eq "Translation_Start_Site" or  $type eq "Frame_Shift_Del" or $type eq "Frame_Shift_Ins" or $type eq "In_Frame_Ins" or $type eq "In_Frame_Del" or $type eq "Missense_Mutation" or $type eq "Nonstop_Mutation" or $type eq "Nonsense_Mutation" or $type eq "Splice_Site"){
            $mut{$cgnc}=1;
        }
        else {
            $mut{$cgnc}=0;
        }
    }
}
close MUTATION;



open OUT, ">data4muffin.txt" or die $!;
foreach my $gene (keys %mut){
    if (exists $pairs{$gene} and $mut{$gene}>0){
        print OUT "$pairs{$gene}\t$mut{$gene}\n";
    }
}

close OUT;




