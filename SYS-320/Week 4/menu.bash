#!/bin/bash

# Storyline: Menu for admin, VPN, and Security functions

function invalid_opt() {
	
	echo ""
	echo "Invalid option!"
	echo ""
	sleep 2

}

function menu() {

	# clears the screen
	clear
	
	echo "[1] Admin Menu"
	echo "[2] Security Menu"
	echo "[3] Exit"
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
	
		1) admin_menu
		;;
		
		2) security_menu
		;;
		
		3) exit 0
		;;
		
		*)
			invalid_opt
			
			# Call the main menu
			menu
		
		;;
	esac
	
}

function admin_menu() {

	clear
	echo "[L]ist Running Processes"
	echo "[N]etwork Sockets"
	echo "[V]PN Menu"
	echo "[4] Exit"
	read -p "Please enter a choice above: " choice
	
	case "$choice" in
	
		L|l) ps -ef |less
		;;
		N|n) netstat -an --inet|less
		;;
		V|v) vpn_menu
		;;
		4) exit 0
		;;
		
		*)
			invalid_opt
			
			admin_menu
		;;
	esac
	
admin_menu
}

function vpn_menu() {
	
	clear
	echo "[A]dd a peer"
	echo "[D]elete a peer"
	echo "[C]heck if peer exists"
	echo "[B]ack to admin menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please select an option: " choice
	
	case "$choice" in
	
		A|a) 
		
			bash peer.bash
			
		;;
		D|d) 
		
			read -p "Which user would you like to delete?" user
			bash manage-users.bash -d -u ${user}
			read -p "Press any button to continue:" response
			
		;;
		C|c)
			
			read -p "Which user would you like to check?" user
			bash manage-users.bash -c -u ${user}
			read -p "Press any button to continue:" response
			
		;;	
		B|b) admin_menu
		;;
		M|m) menu
		;;
		E|e) exit 0
		;;
		*)
			invalid_opt
			
			vpn_menu
		;;

	esac
	
vpn_menu
}

function block_list_menu() {
   clear
   echo "[C]isco blocklist generator"
   echo "[D]omain URL blocklist generator"
   echo "[W]indows blocklist generator"
   echo "[B]ack to security menu"
   echo "[E]xit"
   read -p "Please select an option: " choice

   case  "$choice" in
       C|c)
       		source parse-threat.bash
			cisco
       ;;

       D|d)
       	    source parse-threat.bash
			url_filters

       ;;

       W|w)
            source parse-threat.bash
			windows_firewall

       ;;
	   
   	   B|b) security_menu
	   
	   ;;
	   
       E|e) exit 0
       ;;

       *)
           invalid_opt
		   
		   block_list_menu
       ;;

   esac
}

function security_menu() {

	clear
	echo "[N]etwork Sockets"
	echo "[R]oot UID check"
	echo "[L]ast 10 users"
	echo "[C]urrent user(s)"
	echo "[B]lock list menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please select an option: " choice
	
	case "$choice" in
	
		N|n) netstat -an --inet|less
		;;
		R|r) 
		
		if [[ "$(cut -d: -f1,3 /etc/passwd | grep -v "root:0" | grep ":0")" != "" ]]; 
		then
			
			echo "User other than root with UID 0 found"
		
		else
		
			echo "No user besides root has UID 0."
	
		fi
		read -p "Press any button to continue: " response
		;;
		L|l) last -n 10 |less
		;;
		C|c) who |less
		;;
		B|b) block_list_menu
		;;
		M|m) menu
		;;
		E|e) exit 0
		;;
		*)
			invalid_opt
			
			security_menu
		;;
	
	esac

security_menu
}


# Call the main function
menu
