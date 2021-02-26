# This script is to gelocate all the prefixes in EXTRA or GRAPHS folder using either MAXMIND or IPINFO API
# & save it in the RESULTS dir (cur dir)
# It uses 2 different APIs -> Maxmind & IPinfo
# Only 1 API can be used at a time
#
# Algo -
# Traverse through all the files (prefixes) in the given folder recursively
# Separated by subnets -
# For /24 - Check for (a.b.c.50) + (a.b.c.150)
# For /23 - Check for (a.b.c.100) + (a.b.c+1.100)
# For /22 - Check for (a.b.c.100) + (a.b.c+3.100)
# For /21 - Check for (a.b.c.100) + (a.b.c+4.100)  + (a.b.c+7.100)
# For /20 - Check for (a.b.c.100) + (a.b.c+7.100)  + (a.b.c+15.100)
# For /19 - Check for (a.b.c.100) + (a.b.c+15.100) + (a.b.c+31.100)
# For /18 - Check for (a.b.c.100) + (a.b.c+31.100) + (a.b.c+63.100)
# For /17 - Check for (a.b.c.100) + (a.b.c+63.100) + (a.b.c+127.100)
# For /16 - Check for (a.b.c.100) + (a.b.c+127.100) + (a.b.c+250.100)
# Perform geolocation for all IPs
# Keep appending the results in nested py dicts -> keys : value -> prefix1 : {IP1 : {result}, IP2 : {result}... }, prefix2 : {..} ...   
# Dump the py dicts to CSV file
#
# Usage -> $ python3 ipInfo_Geolocation.py MAXMIND FOLDER CSV_FILE
# Usage -> $ python3 ipInfo_Geolocation.py IPINFO FOLDER CSV_FILE
#
# Output -> CSV_FILE with geolocation of prefixes in FOLDER
#
# FOLDER -> EXTRA or GRAPHS [make sure in same dir as this file]
# CSV_FILE -> ipInfo_US_202102_GRAPHS.csv [sample]
#

from os import walk
from sys import argv, exit
import geoip2.webservice
import ipinfo

# set API params
client = geoip2.webservice.Client(447809, 'fPcmU1LrNeljuyaV')
handler = ipinfo.getHandler(access_token='30e2106bb3573e', request_options={'timeout': 30})

### CLI ARGS for [GEOLOCATION method], [prefix folder] & [output CSV filename]
API = argv[1]
FOLDER = argv[2]
OUTPUT_FILE = argv[3]


def get_prefixes(FOLDER):

    # nested list with each element as -> [ISP, ASN, IP, subnet, {}]
    # where each dict contains -> {IP1 : {city: city, state: state}, IP2 ...}
    prefixes = []

    for root, dir, f in walk(FOLDER):
        for fname in f:

            # root dir fname
            # GRAPHS/GRANDE_AS7459_graphs [] 66.90.129.0_24.html
            ISP, ASN, graphs = root.split('/')[1].split('_')
            prefix = fname[:-5] if FOLDER == 'GRAPHS' else fname[:-11]

            IP = prefix[:-3]
            subnet = prefix[-2:]

            prefixes.append([ISP, ASN, IP, subnet, {}])

    return prefixes

def ipinfo_maxmind_query(IP, prefix):

    # add empty nested for city & state for IP
    prefix[-1][IP] = {'city':None, 'state':None}

    if API == 'MAXMIND':
        response = client.city(IP)
        prefix[-1][IP]['city'] = response.city.name
        prefix[-1][IP]['state'] = response.subdivisions.most_specific.name

    elif API == 'IPINFO':
        try:
            details = handler.getDetails(IP)
            prefix[-1][IP]['city'] = details.city
            prefix[-1][IP]['state'] = details.region
        except:
            print("TIMEOUT IPINFO")

    else:
        print("Invalid API Input! Halting")
        exit(0)


### function to add add_value to 3rd bit of IP, returns a.b.(c+add_value).(d+100)
def get_IP(IP, add_value):
    tmp = IP.split('.')
    return tmp[0]+'.'+tmp[1]+'.'+str(int(tmp[2])+add_value)+'.100'


def geolocation(prefix, FILE, count, total):

    if prefix[3] == '24':
        IP = prefix[2][:-1]+'50'
        ipinfo_maxmind_query(IP, prefix)
        
        IP = prefix[2][:-1]+'150'
        ipinfo_maxmind_query(IP, prefix)

    elif prefix[3] == '23':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 1), prefix)

    elif prefix[3] == '22':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 3), prefix)
        
    elif prefix[3] == '21':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 3), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 6), prefix)

    elif prefix[3] == '20':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 6), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 12), prefix)

    elif prefix[3] == '19':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 15), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 30), prefix)

    elif prefix[3] == '18':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 30), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 60), prefix)
    
    elif prefix[3] == '17':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 60), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 120), prefix)

    elif prefix[3] == '16':
        IP = prefix[2][:-1]+'100'
        ipinfo_maxmind_query(IP, prefix)

        ipinfo_maxmind_query(get_IP(prefix[2], 120), prefix)
        ipinfo_maxmind_query(get_IP(prefix[2], 250), prefix)

    # prefix -> [ISP, ASN, IP, subnet, {}]
    txt = prefix[0] + '_' + prefix[1] + ', ' + prefix[2] + '/' + prefix[3] + ', ' + str(prefix[4]) + '\n'
    print('#{}/{} -> {}'.format(count, total, txt))

    # write final row for the prefix
    FILE.write(txt)



############ main

def main():

    prefixes = get_prefixes(FOLDER)

    count = 0
    total = len(prefixes)

    FILE = open(OUTPUT_FILE, 'a')
    FILE.write('ISP_ASN, prefix, {geolocation}\n')

    for prefix in prefixes:
        geolocation(prefix, FILE, count, total)
        count+=1

    FILE.close()

main()
