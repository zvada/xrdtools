#!/bin/bash
#
# Find all processes that are executing a futex(2) call with op=FUTEX_WAIT
# In some cases this can be helpful in finding deadlock-ed processes.
#

source /etc/profile

THISHOST=$(hostname --long) 
DATE=$(date +%D-%T)
#EMAIL=marian.zvada@cern.ch,bbockelm@cse.unl.edu
#EMAIL=ANYDATA@listserv.unl.edu
EMAIL=marian.zvada@cern.ch

process=""
FILE=/tmp/deadlock-process.log

( [ -e "$FILE" ] || touch "$FILE" )

test ! $UID -eq 0 && echo -e "WARNING: Not running as root, only processes for this user are being scanned\n" >&2;

pids=$(ps -u $UID -opid --no-headers)
 
for pid in $pids; do

    deadPID=$(cat /proc/$pid/syscall |
              awk "{if (\$1 == 202 && \$3 == \"0x0\") {
                   print $pid
              }}";) 
        # $1 is the syscall, we compare to 202 which is the futex call
        # See: /usr/include/asm/unistd.h
 
        # $2 is the 1st param, $3 is the 2nd param, etc
        # We compare the second param to 0x0 which is FUTEX_WAIT
        # See: /usr/include/linux/futex.h

#    ! [[ -z "$deadPID" ]] && echo $deadPID >> $file
    if [[ ! -z "$deadPID" ]]; then
        process=`ps -ef | grep $deadPID | grep -v grep`
        echo "$DATE $process" >> $FILE 
        echo -e "WARNING: deadlock found in process:\n$process\n\nStatus on $THISHOST.\n\nPlease investigate.\n\n$DATE" | mail -s "WARNING: deadlock found in PID: $deadPID" $EMAIL
    fi
done

[[ -z "$process" ]] && rm -rf $FILE
