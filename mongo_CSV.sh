#!/bin/bash

# A script to make CSVs after matching prefix frequencies from mongoDB collections

############################# GLOBAL VARS ##################################

vars=("$@")

TIME_1=${vars[30]}               # timestamp 1
TIME_2=${vars[31]}               # timestamp 2
TIME_3=${vars[32]}               # timestamp 3
TIME_4=${vars[33]}               # timestamp 4
ISP_ASN=${vars[34]}              # folder name for ISP_ASN
LIMIT=${vars[35]}		         # limit for graphs

#############################################################################

echo "Making CSV files now..." >> logs.txt

for F in $(ls ${ISP_ASN})
do

    (ASN=$(echo $F | cut -d "_" -f 2)

    for prefix in $(cat ${ISP_ASN}/${F})
    do

    for i in {0..29}
    do
        for TIME in {"${TIME_1}","${TIME_2}","${TIME_3}","${TIME_4}"}
        do
            echo -n "${vars[${i}]},${TIME},${ASN},${prefix}," >> ${F}_database.csv
            mongo --quiet --eval "db.getCollection('${TIME}').find({ PREFIX: '${prefix}' }).count();" ${vars[${i}]} >> ${F}_database.csv
        done
    done
    echo "0,0,0,0,0" >> ${F}_database.csv
    echo "Done for ${prefix}"
    done) &
    wait_buffer+=($!)
    echo "Making CSV for ${F}" >> logs.txt

done

for PID in "${wait_buffer[@]}"; do wait ${PID}; done
wait_buffer=()

echo "Inserting CSV headers..." >> logs.txt


for F in $(ls | grep _database.csv); do sed  -i '1i DATE,TIME,ASN,PREFIX,FREQ' ${F}; done

echo "DONE!" >> logs.txt

##########################################################

echo -e "\nCOMPLETED PHASE 3 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 3 successfully! All CSV files have been made!"

##########################################################

