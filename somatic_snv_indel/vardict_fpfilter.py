# Usage:

# cd /scratch/steep/7callers/vardict_results

#python ./scripts/vardict_fpfilter.py \
#S1.vcf \
    #S1_fpfiltered.vcf

######################################
import sys # This is a module to be imported for the next two lines allowing the script to take an input and output file as arguments

infile=sys.argv[1] # This tells the Python script that the second file in the arguments (script is file 1) is the infile. Remember python is zero based

outfile=open(sys.argv[2], 'w') # This tells the pythin script that the third file is the outfile and tells python to write to that file ('w' is for write)

for line in open(infile): # A for loop for each line in the file
  if line[0] == '#':
    outfile.write(line) # For each line that begins with #, the header, write it to the file
  if not line[0] == '#': # For each line after the header
    columns = line.split('\t') # Split the line by tabs to make variable named columns
    status = (columns[7].split(';'))[0].split('=')[1] # Takes the "STATUS=StrongSomatic" string and chooses for the substring after the equal sign, we will later choose for 'StrongSomatic'
    status_title = ((columns[7].split(';'))[0].split('=')[0])
    var_type = (columns[7].split(';')[2].split('=')[1]) # Takes the "TYPE=SNV" string and chooses for the substring after the equal sign, we will later choose for 'SNV'
    var_type_title = (columns[7].split(';')[2].split('=')[0])
    filter_vcf = columns[6] # Takes the values in the 7th column and assigns to variable filter, we will later choose for 'PASS'
    DP_title = (columns[8].split(':')[1]) # Makes sure that the value we are filtering is for DP, that this variable captures 'DP'
    DP = int(columns[9].split(':')[1]) # We know that DP was choosen so now we choose the numerical value in the next column of the vcf
    VD_title = (columns[8].split(':')[2])
    VD = int(columns[9].split(':')[2])
    MQ_title = (columns[8].split(':')[14])
    MQ = float(columns[9].split(':')[14])
    SBF_title = (columns[8].split(':')[12])
    SBF = float(columns[9].split(':')[12])
    if status_title != 'STATUS':
        print(line)
        print('Error: STATUS out of position')
        sys.exit()
    if var_type_title != 'TYPE':
        print(line)
        print('Error: VAR TYPE out of position')
        sys.exit()
    if DP_title != 'DP':
        print(line)
        print('Error: DP out of position')
        sys.exit()
    if VD_title != 'VD':
        print(line)
        print('Error: VD out of position')
        sys.exit()
    if MQ_title != 'MQ':
        print(line)
        print('Error: MQ out of position')
        sys.exit()
    if SBF_title != 'SBF':
        print(line)
        print('Error: SBF out of position')
        sys.exit()
    if status == 'StrongSomatic' and (var_type == 'Insertion' or var_type == 'Deletion' or var_type == 'Complex' or var_type == 'SNV') and filter_vcf == 'PASS':
        if DP >= 6:
            if VD >= 2:
                if MQ >= 20.0:
                    if SBF >= 0.01:
                        outfile.write(line)
print('Finished')
######################################
