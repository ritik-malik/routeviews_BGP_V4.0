#!/bin/bash

# A script to add indexing at prefix 1 on all collections in mongoDB

vars=("$@")

TIME_1=${vars[30]}
TIME_2=${vars[31]}
TIME_3=${vars[32]}
TIME_4=${vars[33]}

wait_buffer=()      # buffer to store PID, run them //ly

for i in {0..29}
do
    for TIME in {"${TIME_1}","${TIME_2}","${TIME_3}","${TIME_4}"}
    do

        mongo --quiet --eval "db.getCollection('${TIME}').createIndex({PREFIX:1});" ${vars[${i}]} &
        wait_buffer+=($!)
        echo "Making index for ${vars[${i}]}.${TIME}" >> logs.txt
    done
done

for PID in "${wait_buffer[@]}"; do wait ${PID}; done
wait_buffer=()

echo "Done!" >> logs.txt

##########################################################

echo -e "\nCOMPLETED PHASE 2 successfully!\nSending an email" >> logs.txt
python3 mail.py "COMPLETED PHASE 2 successfully! Indexing has been done for mongoDB!"

##########################################################
