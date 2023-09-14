#! /bin/bash

hostfile=$1
portfile=$2
if [ ! -f $hostfile ]; then
  echo "Error: hostfile does not exist"
  exit 1
fi
if [ ! -f $portfile ]; then
  echo "Error: portfile does not exist"
  exit 1
fi
echo "host,port"
for host in $(cat $hostfile); do
	for port in $(cat $portfile); do
		timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && echo "$host,$port"
	done
done
