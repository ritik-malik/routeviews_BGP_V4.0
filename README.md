# routeviews_BGP_V4.0

New & improved pipeline from  _[routeviews_BGP_V3.0](https://github.com/ritik-malik/routeviews_BGP_V3.0/)_ <br>
**Beta version** <br>

### Major upgradations in new pipeline
* Dates are flexible, not hardcoded for 1 month, can use any 30 days
* Support removed for mongoDB, replaced by py dictioneries _\(much faster!)_
* Execution time less than half day, compared to 1.5 days previously
* Efficient storage : Using pickle to store dicts as binaries
* More intutive input for scripts
* Each script has little man page inside for debugging
* This time no need to scrap prefixes, use the ribs itself

### Pipeline flow

#### pipeline.sh
* Input YYYY MM & DD until 30 days are covered (new UI)
* Input 4 timestamps (0200 0800 1400 2000 recommended for better coverage)
* Input ISP_ASN folder name + LIMIT for graphs
* Perform sanity check for all files
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
 `.`<br>
`${vars[34]} = LIMIT XX` <br>
 <br>
This array is passed to master.sh <br>


#### What's next?
To get better insight of actual approach & hypothesis -
* Read plan.txt
* Each script has a little doc inside <br>
Start from `pipeline.sh`, it will lead to all other scripts

### Some interesting stats :
The results are out from new pipeline for ribs from `14th Jan` to `12th Feb` \(for India) :- <br>
\(This is important to analyse as these are the results from the 1st run) <br>

**Some good stuff -**
* New pipeline now runs in 7 hours, compared to 40 hours previously!
* The hypothesis was right, we got overall more prefixes from ribs than from CIDR,<br>
`CIDR prefixes -> 19884` <br>
`Ribs prefixes -> 20720` <br>
(834 new prefixes)
* Storage space or RAM is not an issue now , new pipeline is quite optimized <br>
Storage < 500 MB, RAM < 6 GB
* We got more number of prefixes with dips > 20% in ribs <br>
`Old pipeline : 356` <br>
`New pipeline : 1205` <br>
And that's insane! <br>

**Some bad news -**
* There seems to be very little correlation, but could be just coincidence, <br>
Only a very small fraction of graphs falling in the right spot, on the days of shutdown <br>
\(this is only for India) <br>
\(we got perfect correlatin for Iran & Myanmar) <br>

**A major concern :** <br>
We still don't get it...?<br>
If these dips in graphs are not for shutdowns, then why are they for though, <br>
We didn't see same pattern anywhere else! <br>

_**Update this doc**_













