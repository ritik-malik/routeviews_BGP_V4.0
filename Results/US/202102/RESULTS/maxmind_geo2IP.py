import os
import geoip2.webservice

# A script to geolocate all the prefixes found recursively in folder,
# (like in the GRAPHS & EXTRA folder from the pipeline output)
# using the MaxMind Geo2IP API
# Different test for each each subnet -
# For /24 - Check for (a.b.c.50) + (a.b.c.150)
# For /23 - Check for (a.b.c.100) + (a.b.c+1.100)
# For /22 - Check for (a.b.c.100) + (a.b.c+3.100)
# For /21 - Check for (a.b.c.100) + (a.b.c+4.100)  + (a.b.c+7.100)
# For /20 - Check for (a.b.c.100) + (a.b.c+7.100)  + (a.b.c+15.100)
# For /19 - Check for (a.b.c.100) + (a.b.c+15.100) + (a.b.c+31.100)
# For /18 - Check for (a.b.c.100) + (a.b.c+31.100) + (a.b.c+63.100)
#
############### GLOBAL VARS ##################

output_file = 'Maxmind_US_202102_EXTRA.csv'
input_folder = 'EXTRA'

############### GLOBAL VARS ##################
# 
# Make sure you set the global vars correctly
# Usage -> python3 maxmind_geo2IP.py
# Output -> A CSV file with prefixes & their GEO2IP location db

# set API params
client = geoip2.webservice.Client(447809, 'fPcmU1LrNeljuyaV')

count = 0
prefix = []

csv_file = open(output_file, 'a')
csv_file.write('ISP_ASN, IP, state, check1, check2, check3\n')

def geolocate(IP):
    response = client.city(IP)
    city = response.city.name
    state = response.subdivisions.most_specific.name

    if city == None:
        return 'None', 'None'

    return city, state


for root, dir, f in os.walk(input_folder):
    for fname in f:
        if fname.endswith('.html'):
            fol, fol_name = root.split('/')
            ISP, ASN, tmp = fol_name.split('_')
            ISP_ASN = ISP + '_' + ASN

            IP, subnet = fname[:-5].split('_')

            # print(ISP_ASN, IP, subnet)

            a,b,c,d = IP.split('.')

            if subnet == '24':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 50)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 150)
                city2, state2 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '23':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 1) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '22':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 3) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '21':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 4) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 7) + '.' + str(int(d) + 100)
                city3, state3 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2 + ', ' + city3
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '20':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 7) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 15) + '.' + str(int(d) + 100)
                city3, state3 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2 + ', ' + city3
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '19':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 15) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 31) + '.' + str(int(d) + 100)
                city3, state3 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2 + ', ' + city3
                csv_file.write(txt)
                csv_file.write('\n')


            elif subnet == '18':
                IPx = a + '.' + b + '.' + c + '.' + str(int(d) + 100)
                city1, state1 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 31) + '.' + str(int(d) + 100)
                city2, state2 = geolocate(IPx)
                IPx = a + '.' + b + '.' + str(int(c) + 63) + '.' + str(int(d) + 100)
                city3, state3 = geolocate(IPx)

                txt = ISP_ASN + ', ' + IP + '/' + subnet + ', ' + state1 + ', ' + city1 + ', ' + city2 + ', ' + city3
                csv_file.write(txt)
                csv_file.write('\n')

            count+=1
            print('#{} -> {}'.format(count, txt))

