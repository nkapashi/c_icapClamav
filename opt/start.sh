#!/bin/sh
# start clamd and c-icap service
echo "INFO: Starting up CLAMD service"
/usr/sbin/clamd &
sleep 5
echo "INFO: Starting up C-ICAP service"
/opt/c-icap/bin/c-icap -D -d 5
