#!/bin/bash

# Storyline: Script to add and delete VPN peers

while getopts 'hdacu:' OPTION ; do

	case "$OPTION" in
	
	d) u_del=${OPTION}
	;;
	a) u_add=${OPTION}
	;;
	c) u_check=${OPTION}
	;;
	u) t_user=${OPTARG}
	;;
	h)
	
		echo ""
		echo "Usage: $(basename $0) [-a]|[-d]|[-c] -u username"
		echo ""
		exit 1
	
	;;
	
	*)
		
		echo "Invalid value."
		exit 1
	
	;;
	esac

done

# Check to see if the -a, -d, and -c are empty or if they are both specified throw an error
if [[ (${u_del} == "" && ${u_add} == "" && ${u_check} == "") || (${u_del} != "" && ${u_add} != "" && ${u_check} != "") ]]
then

	echo "Please specify -a, -d, or -c and the -u and username."

fi

# Check to ensure -u is specified
if [[ (${u_del} != "" || ${u_add} != "" || ${u_check} != "") && ${t_user} == "" ]]
then 

	echo "Please specify a user (-u)!"
	echo "Usage: $(basename $0) [-a][-d][-c] -u username"
	exit 1
	
fi

# Delete a user
if [[ ${u_del} ]]
then

	echo "Deleting user..."
	sed -i "/# ${t_user} begin/,/# ${t_user} end/d" wg0.conf
	
fi

# Add a user
if [[ ${u_add} ]]
then

	echo "Create the User..."
	bash peer.bash ${t_user}
	
fi
if [[ ${u_check} ]]
then

	if grep -q "# ${t_user} begin" wg0.conf; 
	then
	
		echo "User ${t_user} exists."
		
	else
	
		echo "User ${t_user} does not exist."
		
	fi
	
fi
