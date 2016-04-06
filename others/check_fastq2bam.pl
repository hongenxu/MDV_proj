#!/usr/bin/perl

use strict; 
use warnings; 
use Getopt::Long;

my $sample="";
GetOptions(
            "sample=s"   =>\ $sample);

my $error=`grep -i "error" $sample.*`;
print "ERROR\n$error\n";
my $warnings=`grep -i "warning" $sample.*`;
print "WARNINGS\n$warnings\n";
my $exception=`grep -i "exception" $sample.*`;
print "EXCEPTIONS\n$exception\n";
my $bwa=`grep "Real time" $sample.*`;
print "bwa\n$bwa\n";
my $time=`grep -i "picard.sam.*time" $sample.*`;
print "picard\n$time\n";

my $gatk=`grep -i "^INFO.*done.*100" $sample.*`;
print "gatk\n$gatk\n";

