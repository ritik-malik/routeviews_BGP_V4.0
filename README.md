# routeviews_BGP_V4.0

New & improved pipeline from routeviews_BGP_V3.0 <br>
**Beta version** <br>

### Upgradations in new pipeline
* More intutive input for scripts
* Dates are flexible, not hardcoded for 1 month, can use any 30 days

### Pipeline flow

#### pipeline.sh
* Input YYYY MM & DD until 30 days are covered (new UI)
* Input 4 timestamps (0200 0800 1400 2000 recommended for better coverage)
* Input ISP_ASN folder name + LIMIT for graphs
* Display all the inputs (vars array) + show warning
* Confimation check before proceeding
* Call `master.sh` in background & exit

`Structure of the array VARS :

$vars{[0]} = 1st date [start] YYYYMMDD
$vars{[1]} = 2nd date
$vars{[2]} = 3rd date
.
.
$vars{[29]} = 30th date [end]

$vars{[30]} = timestamp_1 TTTT
$vars{[31]} = timestamp_2 
$vars{[32]} = timestamp_3 
$vars{[33]} = timestamp_4 

${vars[34]} = ISP_ASN [folder name]

${vars[35]} = LIMIT XX

This array is passed to master.sh
#`


#### master.sh
* 














