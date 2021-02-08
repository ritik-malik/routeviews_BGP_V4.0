# routeviews_BGP_V4.0

New & improved pipeline from  _[routeviews_BGP_V3.0](https://github.com/ritik-malik/routeviews_BGP_V3.0/)_ <br>
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

`Structure of the array VARS :` <br>
 <br>
`$vars{[0]} = 1st date [start] YYYYMMDD` <br>
`$vars{[1]} = 2nd date` <br>
`$vars{[2]} = 3rd date` <br>
`.` <br>
`.` <br>
`$vars{[29]} = 30th date [end]` <br>
 <br>
`$vars{[30]} = timestamp_1 TTTT` <br>
`$vars{[31]} = timestamp_2`  <br>
`$vars{[32]} = timestamp_3`  <br>
`$vars{[33]} = timestamp_4`  <br>
 <br>
`${vars[34]} = ISP_ASN [folder name]` <br>
 <br>
`${vars[35]} = LIMIT XX` <br>
 <br>
This array is passed to master.sh <br>


#### master.sh
* 

_**Update this doc**_













