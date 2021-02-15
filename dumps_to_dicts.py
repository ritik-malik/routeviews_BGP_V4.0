from sys import argv
from glob import glob
from pprint import pprint
import pickle

# This script does the following task:
#
# Read target ASes into list from target_ASN.txt in parent folder
# Load the pkl dict, else create a new one
# Read the all the ribs dumps in cur dir matching with argv[1] 
# Append data to dict for those target ASes
# save the dumps
#
# Usage  -> python3 dumps_to_dicts.py 20210215.1400
# Output -> 20210215.1400.pkl
#

def read_target_ASes():
    with open('../target_ASN.txt', 'r') as f:
        AS = f.readlines()
    AS = [x.strip() for x in AS]
    
    temp = []
    for i in AS:
        temp.append(i.split('_')[1])    # Take only AS part from ISP_ASN

    return temp


def load_dict():
    
    # check if the dict already exist 
    try:
        with open(master_dict, 'rb') as handle:
            argv[1] = pickle.load(handle)
    except:
        argv[1] = {}    # else create new empty dict = YYYYMMDD.TTTT
        for i in target_AS:
            argv[1][i] = {}     # makes nested empty dicts

    return argv[1]


def add_data(file):

    with open(file, 'r') as f:
        for line in f.readlines():      # read file line by line, strip \n
            line = line.strip()

            try:
                prefix, ASN = line.split(',')
            except:
                print(line)     # catch error for further debugging
                continue

            if ASN in argv[1]:
                if prefix in argv[1][ASN]:
                    argv[1][ASN][prefix] += 1           # if prefix present in AS, add 1 to freq
                else:
                    argv[1][ASN][prefix] = 1            # if new prefix, add new key to dict


def save_dict():
    with open(master_dict, 'wb') as handle:
        pickle.dump(argv[1], handle)


######################################################################
##### main

argv[1] = str(argv[1])

# the master dict name
master_dict = argv[1] + '.pkl'

# List of ASes to be searched in dumps
target_AS = read_target_ASes()

# load the dict
argv[1] = load_dict()

# read all files with rib.YYYYMMDD.TTTT.*
for file in glob('rib.'+master_dict[:13]+'.*'):
    add_data(file)

save_dict()


# print the master dict
pprint(argv[1])
