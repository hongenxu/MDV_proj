#/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;


my $sample="";
GetOptions(
            "sample=s"   => \$sample);

print "$sample\n";

print "\nbwa\n";

chdir "./bwa";
my @files=<*.sam>;

foreach my $file (@files){
	if ($file=~/_$sample\_/){
		print "$file\n";	
		system "rm $file" if $file=~/.sam/;
	}
	

}
print "\npost_alignment\n";

chdir "../post_alignment";
my @post_files=<*\.*>;

foreach my $file (@post_files){
    if ($file=~/_$sample\_/){
		print "$file\n";
		system "rm $file" if $file=~/.sam/;
		system "rm $file" if $file=~/Bwa_RG.bam/;
	
	}

}

print "\nmerged\n";

chdir "../merged";
my @m_files=<*\.*>;

foreach my $file (@m_files){
	if ($file=~/_$sample\_/){
		print "$file\n";	
	}

}

