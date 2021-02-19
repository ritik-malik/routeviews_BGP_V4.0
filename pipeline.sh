#!/bin/bash

# This the starting script for the new pipeline [the 1st script to be run]
# Initializes and declares all the variables - (dates, time, prefixes, limit, etc.)
# Then pass the array to master.sh
# See EOD for structure of the array - "vars"
# Make sure you are in same dir as all other scripts & it has target_ASN.txt file
# This target_ASN.txt files contains all target ASes that need to be searched in dumps 
# in the format -> ISP_ASN, newline separated
# eg -> AIRTEL-BHARTI_9498
#
# Usage -> ./pipeline.sh

echo
echo "============================================="
echo "<<<======= WELCOME TO THE PIPELINE =======>>>"
echo "============================================="
echo

echo "Checking for all files in current directory..."
ch_files=()
for i in $(ls); do ch_files+=($i); done

if printf '%s\n' "${ch_files[@]}" | grep -q -P '^master.sh$'; then echo "Found master.sh"; else echo -e "master.sh is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^dumps_to_dicts.py$'; then echo "Found dumps_to_dicts.py"; else echo -e "dumps_to_dicts.py is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^generate_ISP_ASN.py$'; then echo "Found generate_ISP_ASN.py"; else echo -e "generate_ISP_ASN.py is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^generate_CSV.py$'; then echo "Found generate_CSV.py"; else echo -e "generate_CSV.py is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^make_graphs.sh$'; then echo "Found make_graphs.sh"; else echo -e "make_graphs.sh is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^bokeh_graphs.py$'; then echo "Found bokeh_graphs.py"; else echo -e "bokeh_graphs.py is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^mail.py$'; then echo "Found mail.py"; else echo -e "mail.py is missing!\nExiting..."; exit; fi
if printf '%s\n' "${ch_files[@]}" | grep -q -P '^routeviews.py$'; then echo "Found routeviews.py"; else echo -e "routeviews.py is missing!\nExiting..."; exit; fi

echo -e "\nCheck complete, found all files...\n"

vars=()
while [ ${#vars[@]} -lt 30 ]
do
    echo -e "`expr 30 - ${#vars[@]}` dates remaining...\n"

    read -p "Enter the year in format YYYY : " YYYY
    cal -y ${YYYY}

    read -p "Select a month MM (01-12) : " MM
    cal -d ${YYYY}-${MM}

    read -p "Enter start date DD : " SD
    read -p "Enter end date DD : " ED

    for i in $(seq -w $SD $ED); do vars+=(${YYYY}${MM}${i}); done
    echo -e "\nTotal ${#vars[@]} dates added..."

done

# check if dates are exactly 30
if [ ${#vars[@]} -ne 30 ]
then 
    echo "Selected dates are not equal to 30, plz try again!"
    echo "Exiting..."
    exit
else
    echo -e "\n30 days confirmed!"
fi


echo
read -p "Enter the 1st timestamp : " TIME_1
read -p "Enter the 2nd timestamp : " TIME_2
read -p "Enter the 3rd timestamp : " TIME_3
read -p "Enter the 4th timestamp : " TIME_4

vars+=(${TIME_1}); vars+=(${TIME_2})
vars+=(${TIME_3}); vars+=(${TIME_4})

echo
echo "Make sure you have a file named 'target_ASN.txt' in the current dir"
echo "It should contain newline seperated ASes to be searched in ribs, eg - AIRTEL-BHARTI_9498"
echo
read -p "Confirm the presence of this file : (y/n) "  check_AS

if [ ${check_AS} != "y" ]
then
    echo "Confirmation failed, exiting!"
    exit    
fi


if [ ! -f target_ASN.txt ]; then
    echo "'target_ASN.txt' file not found!"
    echo "exiting..."
    exit
else
    echo -e "\nFound target_ASN.txt file...\n"
fi


read -p "Enter the max() - min() % LIMIT for making graphs XX : " LIMIT
vars+=(${LIMIT})

echo -e "\n____________________________________________________________\n"
echo -e "Here's what you entered :\n"
for i in "${vars[@]}"; do echo "$i"; done

echo -e "\nTarget ASes in target_ASN.txt :\n"
cat target_ASN.txt


echo -e "\n____________________________________________________________\n"
echo -e '\nAre you sure you want to proceed?\nOnce started the code will run for 5-6 hours,\nonly way to stop it is to kill through\n`ps -ef | grep master.sh`\n& then `kill -9 PID`...\n'
echo -e "____________________________________________________________\n"

read -p 'Please Type : "YES START THE PIPELINE" : ' ans

###########################################################

if [ "${ans}" = "YES START THE PIPELINE" ]; then

    echo "<<<-------This is the log file maintained by the program-------->>>" >> logs.txt
    echo -e "\nCurrent value choosen by user" >> logs.txt
    for i in "${vars[@]}"; do echo "$i"; done >> logs.txt
    echo "Target ASes in target_ASN.txt :" >> logs.txt
    cat target_ASN.txt >> logs.txt
    echo -e "\nNow calling master.sh for main task..." >> logs.txt

    nohup ./master.sh "${vars[@]}" &

    echo -e "\nYou can now sit back and relax while we give you email notifications about the progress...\n"
    echo -e 'Else you can watch the [Official logs in `tail -f logs.txt`] or\n[Unofficial logs in `tail -f nohup.out`]'
    echo -e "You can also close this terminal window safely...\n"

else
    echo -e "Input error detected! Exiting the program...\nBye\n"
fi

# Structure of the array VARS :
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
# This array is passed to master.sh
#
#
