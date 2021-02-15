import os
import sys  

# download data from all mirrors of routeviews for a particular date & timestamp
# output format rib.YYYYMMDD.TTTT.MIRROR
#
# usage -> python routeviews.py YYYYMMDD.TTTT

def get_data(x, URL, mirrors):
        
    for i in mirrors:

        try:        
        # final URL = http://archive.routeviews.org/route-views.chicago/bgpdata/2020.02/RIBS/rib.20200201.1200.bz2
            temp='wget '+URL+i+'/bgpdata/'+x[:4]+'.'+x[4:6]+'/RIBS/rib.'+x+'.bz2'
            os.system(temp)

            path='rib.'+x+'.bz2'                     # path = rib.20200215.1200.bz2
            print("\nRunning bgpscanner....\n")
            temp = 'bgpscanner -o rib.'+x+'.'+i+' '+path
            os.system(temp)
        
            os.remove(path)     # remove .bz2 file
                                # final output is a ribs_dumps from BGPscanner -> rib.YYYYMMDD.TTTT.MIRROR

        except:
            print("\nRIBS_DUMPS_404 -> {}\n".format(x,i))   # for std error msg in nohup.out

URL = 'http://archive.routeviews.org/route-views.'
mirrors = ['chicago','chile','eqix','flix','gorex','isc','kixp','jinx','linx','napafrica','nwax','phoix',
           'telxatl','wide','sydney','saopaulo','sg','perth','sfmix','soxrs','mwix','rio','fortaleza','gixa']

# wget format = 'http://archive.routeviews.org/route-views.chicago/bgpdata/2020.02/RIBS/rib.20200201.1200.bz2'

x = sys.argv[1]

get_data(x, URL, mirrors)
