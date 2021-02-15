#!/bin/bash

# follow up script from pipeline.sh
# download 30 days data from routeviews
# Call all other scripts from here
# server specs : 20 v-CPUs, so run 3 instances at a time, //ly

############ GLOBAL VARS ##############

vars=("$@")

# Structure of the array vars :
#
# $vars{[0]} = 1st date [start] YYYYMMDD
# $vars{[1]} = 2nd date
# $vars{[2]} = 3rd date
# .
# .
# $vars{[29]} = 30th date [end]
#
# $vars{[30]} = timestamp_1 TTTT
# $vars{[31]} = timestamp_2 
# $vars{[32]} = timestamp_3 
# $vars{[33]} = timestamp_4 
#
# ${vars[34]} = LIMIT XX
#
#######################################

# PHASE 1

try=0
wait_buffer=()

# use $i & $try to access vars[dates], it will run till 27+2 = ${vars[29]} = 30th, last date

for (( i=0; i<=27; i+=3 ))
do

    echo -e "\nIteration number #${i} out of 27" >> logs.txt
    echo -e "__________________________________\n" >> logs.txt

    try=0
    ################################## step 1 : data downloading for 3 dates //ly

    while [ ${try} -ne 3 ]      # Use (try+i) to generate 3 consequitive number to be used as index for vars to get 3 dates
    do

        mkdir ${vars[$((i+try))]}
        cp routeviews.py ${vars[$((i+try))]}
        cd ${vars[$((i+try))]}

        python3 routeviews.py ${vars[$((i+try))]}.${vars[30]} &
        wait_buffer+=($!)
        python3 routeviews.py ${vars[$((i+try))]}.${vars[31]} &
        wait_buffer+=($!)
        python3 routeviews.py ${vars[$((i+try))]}.${vars[32]} &
        wait_buffer+=($!)
        python3 routeviews.py ${vars[$((i+try))]}.${vars[33]} &
        wait_buffer+=($!)

        echo "Downloading data for ${vars[$((i+try))]}.${vars[30]}" >> ../logs.txt
        echo "Downloading data for ${vars[$((i+try))]}.${vars[31]}" >> ../logs.txt
        echo "Downloading data for ${vars[$((i+try))]}.${vars[32]}" >> ../logs.txt
        echo "Downloading data for ${vars[$((i+try))]}.${vars[33]}" >> ../logs.txt
        echo "" >> ../logs.txt

        cd ..
        ((try++))
    
    done

    echo "Downloading data for 3 days simultaneously..." >> logs.txt

    for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for data to download
    echo "Done!" >> logs.txt

    wait_buffer=()    # reset array
    try=0             # reset try

    ######################################## step 1 done, now step 2
    ######################################## data filtering & py dicts for 3 days //ly

    while [ ${try} -ne 3 ]
    do
    
        cd ${vars[$((i+try))]}
        rm routeviews.py
        find . -size 0 -delete      # delete empty files

        # now for each dumps in the folder : 
        # 1 -> keep only 2 columns  -----\
        # 2 -> rename the dumps     ------|----> //ly for all files
        # 3 -> remove IPv6 dumps    -----/
        # 4 -> remove bogus dumps   ----/

        for dumps in $(ls)
        do
            echo Trimming ${dumps}
            (awk -F '|' '{ print $2" "$3}' ${dumps} | awk '{print $1 "," $NF}' > ${dumps}.tmp   # keep only 2 columns [prefix, dst_ASN]
            mv ${dumps}.tmp ${dumps}                                 # remove old and rename
            sed -i '/{\|:/d' ${dumps})&                                   # remove IPv6 dumps (with : ) & bogus dumps (with {} )
            # run all of them //ly
            wait_buffer+=($!)
        done

        echo -e "\nHouse keeping in ${vars[$((i+try))]}\n1. Deleting routeviews.py\n2. Deleting empty files\n3. Trimming dumps\n4. Remove & rename\n5. Removing IPv6 dumps\n6. Removing bogus dumps\n" >> ../logs.txt

        for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for cleansing of data
        wait_buffer=()    # reset array

        echo -e "House keeping done successfully\nNow importing data for ${vars[$((i+try))]} in py dictioneries, 4 dicts at a time..." >> ../logs.txt

        # the folder now contains dumps -> rib.YYYYMMDD.TTTT.mirror
        #
        # now make py master dicts
        # python3 dumps_to_dicts.py YYYYMMDD.TTTT
        #
        # the folder will finally contains 4 dicts -> YYYYMMDD.TTTT.pkl -> for 4 timestamps
        # Structure of these dictioneries [nested dicts] ->
        #
        # Dict YYYYMMDD.TTTT = {ASN1 : {'Prefix1': Count},
        #                              {'Prefix2': Count}...,
        #                       ASN2...}
        #
        # Where ASNs are collected from target_ASN.txt file in the parent dir
        # and the dumps are scanned to find unqiue prefixes for these ASNs & their freq

        cp ../dumps_to_dicts.py .

        python3 dumps_to_dicts.py ${vars[$((i+try))]}.${vars[30]} &     # timestamp_1
        wait_buffer+=($!)
        python3 dumps_to_dicts.py ${vars[$((i+try))]}.${vars[31]} &     # timestamp_2
        wait_buffer+=($!)
        python3 dumps_to_dicts.py ${vars[$((i+try))]}.${vars[32]} &     # timestamp_3
        wait_buffer+=($!)
        python3 dumps_to_dicts.py ${vars[$((i+try))]}.${vars[33]} &     # timestamp_4
        wait_buffer+=($!)


        for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for py_dicts
        wait_buffer=()    # reset array

        echo "Imported data successfully!" >> ../logs.txt
        echo "Deleting redundant data..." >> ../logs.txt
        
        rm rib* dumps_to_dicts.py           # remove all files except pickle dicts
        
        # ls | grep -v *.pkl | xargs rm        
        # rm !(*.pkl)

        cd ..
        ((try++))

    done

    echo "Process completed for 3 directories, moving to next..." >> logs.txt

done

echo -e "\nDonwloaded & imported data into pickle dict for 30 days" >> logs.txt

##########################################################

echo -e "\nCOMPLETED PHASE 1 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 1 successfully! Data is downloaded & imported to mongoDB!"

##########################################################

# PHASE 2
#
# Now we have 30 folders -> YYYYMMDD
# & each folder has 4 files for 4 timestamps -> YYYYMMDD.TTTT.pkl
# Now create a new folder ISP_ASN
# Make files for each target_AS & append them with unique prefixes from .pkl files

echo -e "\nNow generating ISP_ASN..." >> logs.txt

mkdir ISP_ASN
python3 generate_ISP_ASN.py

echo -e "\nCheck new ISP_ASN folder for files with unique prefixes!" >> logs.txt

##########################################################

echo -e "\nCOMPLETED PHASE 2 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 2 successfully! Unique prefixes have been appended in ISP_ASN!"

##########################################################

wait_buffer=()
echo -e "\nMaking CSV files now...\n" >> logs.txt

for F in $(ls ISP_ASN)
do
    echo "Making CSV for $F" >> logs.txt
    python3 generate_CSV.sh $F &            # call for all ISP_ASN //ly
    wait_buffer+=($!)
done

for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for CSVs
wait_buffer=()    # reset array

##########################################################

echo -e "\nCOMPLETED PHASE 3 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 3 successfully! All CSV files have been made!"

##########################################################

# Now cur dir has ISP_ASN_database.csv files
# make graphs from CSV files

/bin/bash make_graphs.sh "${vars[34]}"

##########################################################

echo -e "\nEverything is ready for you!\n" >> logs.txt
echo -e "___________________________________________\n" >> logs.txt

##########################################################
