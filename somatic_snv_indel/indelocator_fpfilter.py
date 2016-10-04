# Usage:

# cd /scratch/steep/7callers/indelocator_results

# python ./scripts/indelocator_fpfilter.py \
# ./data/S1.vcf \
# ./data/S1_fpfiltered.vcf

# For InDels:
######################################
import sys # This is a module to be imported for the next two lines allowing the script to take an input and output file as arguments
import os
import re
#import numpy as np
#import matplotlib as mpl
#import matplotlib.pyplot as plt
#from scipy import stats
#from scipy.stats import norm

infile=open(sys.argv[1]) # This tells the Python script that the second file in the arguments (script is file 1) is the infile. Remember python is zero based

outfile=open(sys.argv[2], 'w') # This tells the pythin script that the third file is the outfile and tells python to write to that file ('w' is for write)

for line in infile:
  if line[0] == '#': 
    outfile.write(line)
  if not line[0] == '#':
  	if re.search(r'SOMATIC', line):
  		columns = line.split('\t')
  		N_DP_title = (columns[7].split(';')[1].split('=')[0])
  		N_DP = int(columns[7].split(';')[1].split('=')[1])
  		N_MQ_title = (columns[7].split(';')[3].split('=')[0])
  		N_MQ = float(columns[7].split(';')[3].split('=')[1].split(',')[1])
  		N_NQSBQ_title = (columns[7].split(';')[4].split('=')[0])
  		N_NQSBQ = float(columns[7].split(';')[4].split('=')[1].split(',')[1])
  		T_AC_title = (columns[7].split(';')[8].split('=')[0])
  		T_AC = int(columns[7].split(';')[8].split('=')[1].split(',')[0])
  		T_DP_title = (columns[7].split(';')[9].split('=')[0])
  		T_DP = int(columns[7].split(';')[9].split('=')[1])
  		T_MQ_title = (columns[7].split(';')[11].split('=')[0])
  		T_MQ = float(columns[7].split(';')[11].split('=')[1].split(',')[0])
  		T_NQSBQ_title = (columns[7].split(';')[12].split('=')[0])
  		T_NQSBQ = float(columns[7].split(';')[12].split('=')[1].split(',')[0])
  		#Del_size = int(len(columns[3])-len(columns[4]))
  		#T_SC_title = (columns[7].split(';')[14].split('=')[0])
  		#T_SC_VF = int(columns[7].split(';')[14].split('=')[1].split(',')[0])
  		#T_SC_VR = int(columns[7].split(';')[14].split('=')[1].split(',')[1])
  		#T_SC_RF = int(columns[7].split(';')[14].split('=')[1].split(',')[2])
  		#T_SC_RR = int(columns[7].split(';')[14].split('=')[1].split(',')[3])
  		#oddsratio, pvalue = (stats.fisher_exact([[T_SC_VF, T_SC_RF], [T_SC_VR, T_SC_RR]]))
  		if N_DP_title != 'N_DP':
  			print(line)
  			print('Error: N_DP out of position')
  			sys.exit()
  		if N_MQ_title != 'N_MQ':
  			print(line)
  			print('Error: N_MQ out of position')
  			sys.exit()
  		if N_NQSBQ_title != 'N_NQSBQ':
  			print(line)
  			print('Error: N_NQSBQ out of position')
  			sys.exit()
  		if T_AC_title != 'T_AC':
  			print(line)
  			print('Error: T_AC out of position')
  			sys.exit()
  		if T_DP_title != 'T_DP':
  			print(line)
  			print('Error: T_DP out of position')
  			sys.exit()
  		if T_MQ_title != 'T_MQ':
  			print(line)
  			print('Error: T_MQ out of position')
  		if T_NQSBQ_title != 'T_NQSBQ':
  			print(line)
  			print('Error: T_NQSBQ out of position')
  		#if T_SC_title != 'T_SC':
  		#	print(line)
  		#	print('Error: T_SC out of position')
  		if N_DP >= 6:
  			if N_MQ >= 20.0:
  				if N_NQSBQ >= 25.0:
  					if T_AC >= 2:
  						if T_DP >= 6:
  							if T_MQ >= 20.0:
  								if T_NQSBQ >= 25.0:
  									#print(pvalue)
  									outfile.write(line)
print('Finished')
######################################




