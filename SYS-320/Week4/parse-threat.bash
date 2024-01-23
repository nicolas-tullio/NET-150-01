#!/bin/bash

# Storyline: Extract IPs from emerging threats.net and create a firewall ruleset.


# Regex to extract the networks
# 5.      134.     128.     0/     19
#[asking for numerical characters]{looking for numbers 1-3}\search for a literal .

threats_file="/tmp/emerging-drop.suricata.rules"

echo "${threats_file}"

# Check to see if the emerging threats file exists prior to downloading it

if [[ -f "${threats_file}" ]]
	echo ""
	echo "..."
then
	#Prompt the download - ask if it should be downloaded again
	echo "The file ${threats_file} exists."
	echo -n "Would you like to download it again? [y|N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "y" || "${to_overwrite}" == "Y" ]]
	then
		# if yes, download the file using wget
		echo "Downloading the file..."
		echo "..."
		wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules
	elif [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
	then
		# if no, exit
		echo "Exit..."
		exit 0

	fi
fi

egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt

function invalid_opt() {
	echo " "
	echo "Invalid option"
	echo " "
	sleep 2

}

function firewall_rules() {

	echo "[1] iptables"
	echo "[2] cisco"
	echo "[3] windows firewall"
	echo "[4] Mac OS X"
	echo "[5] Parse targetedthreats.csv file"
	echo "[6] Exit"
	read -p "Please select an option: " choice

	case "$choice" in

		1) ip_tables
		;;

		2) cisco
		;;

		3) windows_firewall
		;;

		4) mac_os_x
		;;

		5) parse_file
		;;

		6) exit 0
		;;

		*)
			invalid_opt

			#call the firewall_rules menu
			firewall_rules
		;;

	esac

}

# Create a Firewall ruleset
function ip_tables() {

	for eachIP in $(cat badIPs.txt)
	do
		echo "iptables -A INPUT  -s ${eachIP} -j DROP" | tee badIPs.iptables
	done
	firewall_rules
}

function cisco() {

	# This configuration  denies all packets from the designated hosts through Ethernet 0 on R1 and will permit everything else
	# This can be modified for a different router or ethernet port, but I will be using R1 and eth0 for simplicity's sake

	echo -e '
	hostname R1\n
	!\n
	interface ethernet0
	  ip access-group 1 in\n
	!
	' | tee cisco.conf
	
	for eachIP in $(cat badIPs.txt)
	do 
		echo "access-list deny host ${eachIP}"  | tee -a cisco.conf
	done
	echo "access-list 1 permit any" | tee -a cisco.conf
	firewall_rules
}

function windows_firewall() {

	#This will create a command that can be run via the command line to deny the input of packets from a list of IPs
	
	for eachIP in $(cat badIPs.txt)
	do 
		echo 'netsh advfirewall firewall add rule name="BLACKLIST" dir-in action=block remoteip='${eachIP} | tee -a windows_firewall.ps1
	done
	firewall_rules
}

function mac_os_x() {
	echo -e '

		scrub-anchor "com.apple/*"\n
		nat-anchor "com.apple/*"\n
		rdr-anchor "com.apple/*"\n
		dummynet-anchor "com.apple/*"\n
		anchor "com.apple/*"\n
		load anchor "com.apple" from "/etc/pf.anchors/com.apple"

	' | tee pf.conf
	
	for eachIP in $(cat badIPs.txt)
	do
		echo "block in from" ${eachIP} "to any" | tee -a pf.conf
	done
	firewall_rules
}

function parse_file() {
	
	second_threats_file="/tmp/targetedthreats.csv"
	 
	echo "${second_threats_file}"

	# Check to see if the emerging threats file exists prior to downloading it
	
	if [[ -f "${second_threats_file}" ]]
	     echo ""
	     echo "..."
	then
	    #Prompt the download - ask if it should be downloaded again
	    echo "The file ${second_threats_file} exists."
	    echo -n "Would you like to download it again? [y|N]"
	    read to_overwrite
	
	    if [[ "${to_overwrite}" == "y" || "${to_overwrite}" == "Y" ]]
	    then
	        # if yes, download the file using wget
	        echo "Downloading the file..."
	        echo "..."
	        wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	    elif [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" ]]
	    then
	        # if no, exit
	        echo "Exit..."
	        exit 0
	
	     fi
	fi
	url_filters
}

function url_filters() {
	# the next portion of code will create a ruleset for the cisco url filters

	# don't think this is actually needed unless you want to echo every bad IP 
    # for eachIP in $(cat badIPs.txt)
    # do
    #     echo "class-map match-any" ${eachIP} | tee -a url_filters.txt
    # done
	clear
	
	echo "class-map match-any BAD_URLS" | tee url_filters.txt
	
	grep domain targetedthreats.csv | awk ' { print $1 } ' | cut -d\, -f2 | tee domain.txt

    for domain in $(cat domain.txt)
    do
        echo "match protocol http host" ${domain}  | tee -a url_filters.txt
    done
	
	firewall_rules
}

# Call the firewall_rules function
firewall_rules