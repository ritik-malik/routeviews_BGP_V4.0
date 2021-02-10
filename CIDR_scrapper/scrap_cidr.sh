#!/bin/bash

### a bash script to scrap prefixes from cidr-report
### Input - read ASN, read ISP
### Output - list of prefixes in syntax - ISP_ASN

echo "!!! WELCOME TO CIDR REPORT SCRAPPER !!!"
echo "---------------------------------------"

read -p "Enter the ASN -> " ASN
read -p "Enter the ISP -> " ISP

output=${ISP}_${ASN}
URL='https://www.cidr-report.org/cgi-bin/as-report?as='${ASN}'&view=2.0'

echo
echo "Downloading prefixes & processing..."

lynx --dump ${URL} > 1
sed -n '/Advertisements/,${p;/Whois/q}' 1 > 2
awk -F " " '{ print $1 }' 2 > 3
egrep "\[.*\]" 3 > 4
sed -e 's/\[[^][]*\]//g' 4 > ${output}
rm 1 2 3 4

echo "Done! Results saved to ${output}"
echo

