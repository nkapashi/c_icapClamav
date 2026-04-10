#!/bin/sh
# start clamd and c-icap service
echo "INFO: Starting up CLAMD service. Waiting for up to a minute for the service to start."
/usr/sbin/clamd &
sleep 30
# Now Wait 30 seconds for Clamd to create the socket
echo "INFO: Going to wait 30 seconds for Clamd to start"
counter=0
while [ ! -S /run/clamav/clamd.sock ]
do
	sleep 1
	counter=$((counter + 1))
	if [ "$counter" -gt 30 ]; then
		echo "ERROR: Clamd did not start. Antivirus scanning will not work. Check logs for additional information."
		break
	fi
done
# Start the icap service	
echo "INFO: Starting up C-ICAP service"
/opt/c-icap/bin/c-icap -D -d 5
