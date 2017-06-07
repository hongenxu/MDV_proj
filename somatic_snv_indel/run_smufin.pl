#!/usr/bin/perl

use strict;
use warnings;

my $input_dir="/home/proj/MDW_genomics/xu/sickle";
my $output_dir="/home/proj/MDW_genomics/xu/smufin";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";
my $smufin="/home/users/xu/smufin_0.9.3_mpi_beta/SMuFin";

##sample identifiers
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");

chdir $output_dir;

foreach my $num  (0..25){
	my $tumor=$tumors[$num];
	my $normal=$normals[$num];
    $tumor=~/\d+_(S\d+)/;
    my $sample=$1;

	open N1, ">normal_fastqs_1.$sample.txt" or die $!;
	open N2, ">normal_fastqs_2.$sample.txt" or die $1;
	open T1, ">tumor_fastqs_1.$sample.txt" or die $!;
	open T2, ">tumor_fastqs_2.$sample.txt" or die $!;

    print "tumor:$tumor\tnormal:$normal\n";
	chdir $input_dir;
	my @t_files=<$tumor\_*Sickle.fastq.gz>;
	my @n_files=<$normal\_*Sickle.fastq.gz>;
    die "error\n" if scalar@t_files==0 or scalar@n_files==0;
	chdir $output_dir;
	foreach my $t_file (@t_files){
		next if $t_file=~/Singles/;

		print T1 "$input_dir/$t_file\n" if $t_file=~/R1/;
		print T2 "$input_dir/$t_file\n" if $t_file=~/R2/;
	}
	foreach my $n_file (@n_files){
		next if $n_file=~/Singles/;
		print N1 "$input_dir/$n_file\n" if $n_file=~/R1/;
		print N2 "$input_dir/$n_file\n" if $n_file=~/R2/;
	}

	print "\n";
	close N1;
	close N2;
	close T1;
	close T2;

	print "mpirun --np 2 $smufin --ref $genome --normal_fastq_1 normal_fastqs_1.$sample.txt --normal_fastq_2 normal_fastqs_2.$sample.txt --tumor_fastq_1 tumor_fastqs_1.$sample.txt --tumor_fastq_2 tumor_fastqs_2.$sample.txt --patient_id $sample  --cpus_per_node 1 \n";

}
