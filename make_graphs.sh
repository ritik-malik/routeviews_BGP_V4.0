#!/bin/bash

# This script will iterate over all CSV files & call bokeh_graphs.py

###################### NOTE ########################

# if you are running this script directly, Syntax ->
# ./make_graphs.sh LIMIT
# where LIMIT is max() - min() freq condition for the graphs to be made
# make sure you are in the dir with *_database.csv files

####################################################

LIMIT=$1

echo "Making graphs now..." >> logs.txt

for FILE_NAME in $(ls | grep _database.csv)
do
  python3.7 bokeh_graphs.py ${FILE_NAME} ${LIMIT} &           # make graphs //ly for each CSV
  wait_buffer+=($!)
  echo "Making graphs from FILE : ${FILE_NAME}" >> logs.txt
done

for PID in "${wait_buffer[@]}"; do wait ${PID}; done
wait_buffer=()

echo "DONE!" >> logs.txt
echo "Now extracting EXTRA graphs..." >> logs.txt

################ Make new folders & move all the graphs

mkdir EXTRA GRAPHS
cp -r *_graphs GRAPHS
mv *_graphs EXTRA

################ Delete *EXTRA & !*EXTRA in folders

for i in $(find GRAPHS -name *EXTRA.html); do rm $i; done
for i in $(find EXTRA -not -name "*EXTRA.html" -type f); do rm $i; done

##########################################################

echo -e "\nCOMPLETED FINAL PHASE 4 successfully!\nSending final email" >> logs.txt
python3 mail.py "COMPLETED FINAL PHASE 4 successfully! Graphs are ready! Go and check them!"

##########################################################
