#!/bin/bash

source /etc/profile

THISHOST=$(hostname --long) 
#NOW=$(date +"%Y%m%d%H%M")
DATE=$(date +%D-%T)
SERVICE=$1
STATUS=`service $1 status`
#EMAIL=marian.zvada@cern.ch,bbockelm@cse.unl.edu
#EMAIL=ANYDATA@listserv.unl.edu
EMAIL=marian.zvada@cern.ch
DESIRED="running"

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided; e.g.: $0 <xrootd_service_name>"

service $SERVICE status | while read line; do 
   for instance in `echo ${line/$SERVICE*/}`; do
       if [[ $line == *$DESIRED* ]]; then 
          echo "`date +%D-%T` $line" > /tmp/$instance-$SERVICE-checkpoint.log
       else
          echo -e "WARNING: $SERVICE is in trouble.\n\nStatus on $THISHOST:\n$STATUS\n\nPlease investigate.\n\n$DATE" | mail -s "WARNING: $instance $SERVICE is in trouble!" $EMAIL
       fi
   done
done
