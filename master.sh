#!/bin/bash

# follow up script from pipeline.sh
# download 30 days data from routeviews
# Call other all other scripts from here
# server has 40 v-CPUs, so run 3 instances at a time

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
# ${vars[34]} = ISP_ASN [folder name]
#
# ${vars[35]} = LIMIT XX
#
#######################################

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
    ######################################## data filtering & mongoDB for 3 days //ly

    while [ ${try} -ne 3 ]
    do

        cd ${vars[$((i+try))]}
        rm routeviews.py
        find . -size 0 -delete      # delete empty files

        for dumps in $(ls)
        do
            echo Trimming ${dumps}
            (awk -F'|' '{ print $2" "$3}' ${dumps} > ${dumps}.tmp    # trim the data
            mv ${dumps}.tmp ${dumps}                                 # remove old and rename
            sed -i 's/\ /,/g' ${dumps}                               # replace ' ' with ',' AND # add csv header
            sed  -i '1i PREFIX,PATH1,PATH2,PATH3,PATH4,PATH5,PATH6,PATH7,PATH8,PATH9,PATH10,PATH11,PATH12,PATH13,PATH14,PATH15,PATH16' ${dumps}) &
            wait_buffer+=($!)
        done

        echo -e "\nHouse keeping in ${vars[$((i+try))]}\n1. Deleting routeviews.py\n2. Deleting empty files\n3. Trimming dumps\n4. Replacing whitespace with comma\n5. Inserting CSV header\n" >> ../logs.txt

        for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for cleansing of data
        wait_buffer=()    # reset array

        echo -e "House keeping done successfully\nNow importing data for ${vars[$((i+try))]} in mongoDB, 4 collections at a time..." >> ../logs.txt

        # now mongo import

        FILES_1=rib.${vars[$((i+try))]}.${vars[30]}_*
        (for F in $FILES_1; do mongoimport -d ${vars[$((i+try))]} -c ${vars[30]} --type csv --file "$F" --headerline; done) &
        wait_buffer+=($!)
        FILES_2=rib.${vars[$((i+try))]}.${vars[31]}_*
        (for F in $FILES_2; do mongoimport -d ${vars[$((i+try))]} -c ${vars[31]} --type csv --file "$F" --headerline; done) &
        wait_buffer+=($!)
        FILES_3=rib.${vars[$((i+try))]}.${vars[32]}_*
        (for F in $FILES_3; do mongoimport -d ${vars[$((i+try))]} -c ${vars[32]} --type csv --file "$F" --headerline; done) &
        wait_buffer+=($!)
        FILES_4=rib.${vars[$((i+try))]}.${vars[33]}_*
        (for F in $FILES_4; do mongoimport -d ${vars[$((i+try))]} -c ${vars[33]} --type csv --file "$F" --headerline; done) &
        wait_buffer+=($!)

        for PID in "${wait_buffer[@]}"; do wait ${PID}; done    # wait for mongoimport
        wait_buffer=()    # reset array

        echo "Imported data successfully!" >> ../logs.txt
        echo "Deleting redundant data..." >> ../logs.txt
        rm *

        cd ..
        ((try++))

    done

    echo "Process completed for 3 directories, moving to next..." >> logs.txt

done

## donwloaded & imported data for 30 days

echo "Deleting empty folders..." >> logs.txt
find . -empty -type d -delete


##########################################################

echo -e "\nCOMPLETED PHASE 1 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 1 successfully! Data is downloaded & imported to mongoDB!"

##########################################################

# run script to add index

/bin/bash add_index.sh "${vars[@]}"

##########################################################

# script to search mongo & make CSV
/bin/bash mongo_CSV.sh "${vars[@]}"

##########################################################

# make graphs from CSV files
/bin/bash make_graphs.sh "${vars[35]}"

##########################################################

echo -e "\nEverything is ready for you!\n" >> logs.txt
echo -e "___________________________________________\n" >> logs.txt

##########################################################
