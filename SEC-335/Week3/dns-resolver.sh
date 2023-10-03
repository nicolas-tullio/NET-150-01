#! /bin/bash

ip=$1
dns=$2

echo "dns resolution for $ip.0/24"

for i in $(seq 1 254); do
	nslookup "$ip.$i" "$dns" | grep "name"
done
