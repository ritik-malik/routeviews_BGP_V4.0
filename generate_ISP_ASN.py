import os
from glob import glob
import pickle
from pprint import pprint

# This script is used to generate all unique prefixes from all .pkl files
# prefixes are generated only for those ASes in target_ASN.txt
#
# Steps :
#
# Identify all pkl files from cur dir recursively in a list
# Iterate over all of them
# If there is match for ASN in dict with target_ASN.txt :
# append them in a new dict, if they are unique
# Dump all keys from this new dict in files ISP_ASN in ISP_ASN folder
#
# Usage  -> python3 generate_ISP_ASN.py
# Output -> ISP_ASN folder with unique prefixes for ASes in target_ASN.txt
#

def read_target_ASes():
    with open('target_ASN.txt', 'r') as f:
        ISP_ASN = f.readlines()
    ISP_ASN = [x.strip() for x in ISP_ASN]   # list of ISP_ASN
    
    ASN = []
    ASN_dict = []
    for i in ISP_ASN:
        ASN.append(i.split('_')[1])          # Take only ASN part from ISP_ASN
        ASN_dict.append({})                  # make list of empty dicts

    return ISP_ASN, ASN, ASN_dict


ISP_ASN, ASN, ASN_dict = read_target_ASes()

print(ISP_ASN)
print(ASN)
print(ASN_dict)

pkl_files = [y for x in os.walk('.') for y in glob(os.path.join(x[0], '*.pkl'))]

print(pkl_files)

for i in pkl_files:

    with open(i, 'rb') as handle:
            master_dict = pickle.load(handle)

    for j in range(len(ASN)):                       # iterate over all ASNs
        if ASN[j] in master_dict:                   # if that AS is in .pkl
            for key in master_dict[ASN[j]]:         # iterate over its prefixes
                ASN_dict[j][key] = 0                # append it to ASN_dict at j(th) position


# now ASN_dict has unique prefixes for all ASes in ASN
# now make files from ASN_dict

for i in range(len(ISP_ASN)):

    file = 'ISP_ASN/' + ISP_ASN[i]      # file path eg. -> ISP_ASN/AIRTEL_BHARTI_9498
    with open(file, "w") as f:
        for key in ASN_dict[i]:         # keys for this dict are all unique prefixes
            print(key, file=f)


pprint(ASN_dict)