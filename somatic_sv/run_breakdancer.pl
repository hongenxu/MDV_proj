#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

########installation of breakdancer
#below is from the install file of breakdancer
# --recrusive option is important so that it gets the submodules too
#     $ git clone --recursive https://github.com/genome/breakdancer.git
#     $ cd breakdancer
#     $ mkdir build
#     $ cd build
#
#     $ wget "http://downloads.sourceforge.net/project/samtools/samtools/0.1.19/samtools-0.1.19.tar.bz2"
#     $ tar -jxvf samtools-0.1.19.tar.bz2
#     $ cd samtools-0.1.19
#     $ make
#     $ export SAMTOOLS_ROOT=$(pwd)
#     $ cd ..
#     $ cmake .. -DCMAKE_BUILD_TYPE=release -DCMAKE_INSTALL_PREFIX=/usr/local
#     $ make
#     $ sudo make install


#please also install depending PERL modules, please consider install "cpanm" first, and you can install the following
#modules easily, e.g., cpanm install Math::CDF
#Statistics::Descriptive
#GD::Graph
#Math::CDF

#the filtering steps (i.e., $cmd4, $mcd6) are based on "basic protocol 2" in a paper,
#BreakDancer: Identification of Genomic Structural Variation from Paired-End Read Mapping
#PMID:25152801

#the quality control steps are based on "support protocol 3" in the above paper


### configuration
## bam2cfg - generate analysis configure files for breakdancer_max
my $bam2cfg="/home/users/xu/local/lib/breakdancer-max1.4.3/bam2cfg.pl";
my $breakdancer_max="/home/users/xu/local/bin/breakdancer-max";
my $input_dir="/home/proj/MDW_genomics/xu/final_bam/";
my $output_dir="/scratch/xu/MDV_project/breakdancer_results";
my $genome="/home/proj/MDW_genomics/xu/galgal5/galgal5.fa";

##sample identifiers
my @tumors=("738-1_S1","741-1_S2","756-3_S3","766-1_S4","798-1_S5","833-1_S6","834-2_S7","855-1_S8","863-1_S9","918-3_S10","927-2_S11","834-2_2_S12","911-1_2_S13","777-3_S14","787-2_S15","788-1_S16","794-1_S17","835-1_S18","841-3_S19","842-2_S20","884-2_S21","901-2_S22","906-1_S23","911-1_S24","842-2_2_S25","901-2_2_S26");
my @normals=("738-0_S33","741-0_S34","756-0_S35","766-0_S36","798-0_S41","833-0_S42","834-0_S43","855-0_S46","863-0_S47","918-0_S50","927-0_S51","834-0_S43","911-0_S30","777-0_S37","787-0_S38","788-0_S39","794-0_S40","835-0_S44","841-0_S45","842-0_2_S28","884-0_S48","901-0_2_S29","906-0_S49","911-0_S30","842-0_2_S28","901-0_2_S29");

foreach my $num (0..12,14..25){ ##sample S14 was not included due to failling in quality_control
    my $tumor_bam=join("",$input_dir,$tumors[$num],"_Bwa_RG_dedupped_realigned.bam");
    print "$tumor_bam not exists!\n" if ! -e $tumor_bam;
    my $normal_bam=join("",$input_dir,$normals[$num],"_Bwa_RG_dedupped_realigned.bam");
    print "$normal_bam not exists!\n" if ! -e $normal_bam;

    $tumors[$num]=~/.*_(S\d+)/;
    my $sample=$1;
    system "perl $bam2cfg -g -h  $tumor_bam $normal_bam >$output_dir/$sample.cfg";
    my $test=&quality_control("$output_dir/$sample.cfg");
    if ($test==0){
        print "$sample"," failed in quality control\n";
        #die;
    }
    system "cp ~/template.sh ./$sample.breakdancer.job";
    open JOB, ">>$sample.breakdancer.job"  or die $!;
    my $cmd1="$breakdancer_max $output_dir/$sample.cfg  >$output_dir/$sample.diii";
    my $cmd2="$breakdancer_max  -t  $output_dir/$sample.cfg  >$output_dir/$sample.ctx";

    my ($t_name, $t_dir, $t_suffix) = fileparse($tumor_bam,".bam");
    my ($n_name, $n_dir, $n_suffix) = fileparse($normal_bam,".bam");
    my $cmd3=qq(grep "^#" $output_dir/$sample.diii >$output_dir/$sample.diii.filtered);#extract comment lines to output
    my $cmd4=qq(grep  -v $n_name  $output_dir/$sample.diii |grep -v "^#" >>$output_dir/$sample.diii.filtered);
    my $cmd5=qq(grep "^#" $output_dir/$sample.ctx >$output_dir/$sample.ctx.filtered); #extract comment lines to output
    my $cmd6=qq(grep  -v $n_name  $output_dir/$sample.ctx  |grep -v "^#" >>$output_dir/$sample.ctx.filtered);

    print JOB "$cmd1\n$cmd2\n$cmd3\n$cmd4\n$cmd5\n$cmd6\n";
    close JOB;
    #`qsub -b y -q all.q -l vf=4G -N "bd$sample" "sh $sample.breakdancer.job"`;

}

##################################################################

sub quality_control {
    my $file=shift(@_);
    my $flag=1;
    open CFG, "$file" or die $!;

    while (<CFG>){
        chomp;
        my @elements=split/\t/,$_;
        my $rg=$elements[0];
        $rg=~/readgroup:(.*)/;
        $rg=$1;
        my $mean=$elements[8];
        $mean=~/mean\:(.*)/;
        $mean=$1;
        my $std=$elements[9];
        $std=~/std\:(.*)/;
        $std=$1;
        my $cov=$std/$mean; #coefficient of variation (standard deviation divided by mean)
        my $ctx=0; #initialization in case no 32 flag
        $ctx=$1 if $_=~/\)32\((\S+?)\)/;
        $ctx=~s/\%//;
        if ($rg ne "NA" and $cov<0.3 and $ctx<3 ) {
            $flag=1;
        }
        else {
            $flag=0;
            print "$rg\t$cov\t$ctx\n";
        }

    }
    close CFG;
    return $flag;

}
