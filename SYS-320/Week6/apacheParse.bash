#!/bin/bash

#Parse Apache log


# Read in file

# Arguments using the position, they start at $1
APACHE_LOG="$1"

# Check if file exists 
if [[ ! -f ${APACHE_LOG}  ]]
then
	echo "The specified file doesn't exist."
	exit 1
fi

# Looking for web scanners --> print in a clean format
sed -e "s/\[//g" -e "s/\"//g" ${APACHE_LOG} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | \
awk ' BEGIN { format = "%-15s %-20s %6s %-6s %-5s %s\n"
	printf format, "IP", "Date", "Method", "Status", "Size", "URI"
	printf format, "--", "----", "------", "------", "----", "---"}
 
{ printf format, $1, $4, $6, $9, $10, $7} '

# Look for webscanners, and determine the unique IPs so there are no duplicates
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|woot" ${APACHE_LOG} | \
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u > badIPs.txt


# Firewall rulesets - IPTables
rm badIPs.iptables
for eachIP in $(cat badIPs.txt)
do
	echo "iptables -A INPUT -s ${eachIP} -j DROP" >>  badIPs.iptables
done

echo "IPTables ruleset created."

# Firewall rulesets - Windows firewall
rm windows_firewall.ps1
for eachIP in $(cat badIPs.txt)
do
	echo 'netsh advfirewall firewall add rule name="BLACKLIST" dir-in action=block remoteip='${eachIP} >> windows_firewall.ps1
done

echo "Windows firewall rules created"
echo ""
echo "..."
echo ""
echo "Please see the saved files for iptables and windows firewall rules"