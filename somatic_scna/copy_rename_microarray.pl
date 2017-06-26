#!/usr/bin/perl
#copy CEL files from Alec's folder to a subfoder /home/proj/MDW_genomics/xu/microarray/CEL
#rename CEL files to sample identifier
#generate sexfile.txt required by penncnv-affy
#microarray.csv file was from Alec, the original file is in excel, and I changed it to csv file


use strict;
use warnings;

chdir "/home/proj/MDW_genomics/xu/microarray/";

open FILE,"microarray.csv" or die $!;
`rm ./CEL/*.CEL`;
open OUT, ">sexfile.txt" or die $!;
while (<FILE>){
    chomp;
    my @eles=split/\,/,$_;
    my $name=$eles[1];
    my $id=$eles[3];
    my $sex=$eles[8];
    my ($a,$b)=split(//,$name,2);
    #print "$a\t$b\n";
    my $oldname="";
    if ($b<10){
        $oldname=join("",$a,"0",$b,"_WP-Cheng_101-child-3_P004_",$a,$b);
    }
    elsif ($b>=10) {
        $oldname=join("",$a,$b,"_WP-Cheng_101-child-3_P004_",$a,$b);
    }
    print "$oldname\n";
    my $oldfile=join("","/home/proj/MDW_genomics/affy_microarrays/data/DNALM_CHK_P004/",$oldname,".CEL");
    my $newfile="";
    if (-e $oldfile){
        if ($id=~/^017/ or $id=~/^NoT/){
            $newfile="./CEL/$id.CEL";
        }
        else {
            $newfile="./CEL/$oldname.CEL";
        }
    }
    else {
        print "$oldfile not exists!\n";
    }
    `cp $oldfile $newfile`;
    $sex=~s/Female/female/g;
    $sex=~s/Male/male/g;
    $newfile=~s/.\/CEL\///g;
    print OUT "$newfile\t$sex\n";
}
close FILE;
close OUT;


