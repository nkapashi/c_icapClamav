#!/bin/sh
# start clamd and c-icap service
echo "INFO: Starting up CLAMD service. Waiting for up to a minute for the service to start."
/usr/sbin/clamd &
sleep 30
# Now Wait 30 seconds for Clamd to create the socker
echo "INFO: Going to wait 30 seconds for Clamd to start"
counter=0
while [ ! -f /run/clamav/clamd.sock ]
do
	sleep 1
	$counter + 1
	if [[ counter > 30 ]]; then
		break
		echo "ERROR: Clamd did not start. Antivirus scanning will not work. Check logs for additional information."
	fi
done
# Start the icap service	
echo "INFO: Starting up C-ICAP service"
/opt/c-icap/bin/c-icap -D -d 5