import os
from glob import glob
import pickle
from pprint import pprint
from sys import argv

# This script is used to generate CSV files for a ISP_ASN
# It takes complete path of a prefix file as input
# 
# Steps ->
# Find all .pkl in cur dir recursively
# Sort them [imp]
# Now iterate over all prefixes :
# search their freq in sorted .pkl
# & append the CSV file accordingly
#
#
# Usage -> python3 generate_CSV.py AIRTEL-BHARTI_9498
# Output -> AIRTEL-BHARTI_9498_database.csv
#
# Note - Full path of AIRTEL file should be -> ISP_ASN/AIRTEL_9498
#
#

csv_name = argv[1] + '_database.csv'
with open(csv_name, 'a') as csv_file:
    csv_file.write("DATE,TIME,ASN,PREFIX,FREQ\n")   # add initial header


pkl_files = [y for x in os.walk('.') for y in glob(os.path.join(x[0], '*.pkl'))]
pkl_files.sort()

# sample pkl naming -> ./20210203/20210203.0200.pkl
# sample CSV naming -> 20191101,0200,AS31549,31.56.0.0/18,115

pprint(pkl_files)


with open(csv_name, 'a') as csv_file:

    file = 'ISP_ASN/' + argv[1]
    with open(file, 'r') as f:
        for prefix in f.readlines():      # read file line by line, strip \n
            prefix = prefix.strip()

            # now search this prefix in sorted .pkl & append CSV
            
            for pkl in pkl_files:

                # tmp = 20191101,0200,AS31549,31.56.0.0/18,
                tmp = pkl[11:19] + ',' + pkl[20:24] + ',' + 'AS' + argv[1].split('_')[1] + ',' + prefix + ','

                with open(pkl, 'rb') as handle:
                    master_dict = pickle.load(handle)

                if prefix in master_dict[argv[1].split('_')[1]]:     # if 192.168.1.4 in '9894'
                    tmp += str(master_dict[argv[1].split('_')[1]][prefix]) + '\n'       # add the freq for prefix
                else:
                    tmp += '0\n'        # else add 0 (not found)

                csv_file.write(tmp)
                print(tmp)

            # add breaker after every prefix
            tmp = '0,0,0,0,0\n'
            csv_file.write(tmp)

            print(tmp)
