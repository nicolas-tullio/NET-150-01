#!/bin/bash

# Script to perform local security checks

function checks() {

	if [[ $2 != $3 ]]
	then
		echo -e  "\e[1;31mThe $1 is not compliant. The current policy should be: $2, The current value is $3.\e[0m"
		echo -e "$4"
	else
		echo -e "\e[1;32mThe $1 is compliant. Curent Value $3.\e[0m"
	fi
}

#  Check the password max days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' { print $2 } ')
# Check for password max
checks "Password Max Days" "365" "${pmax}"

# Check the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' { print $2 } ' )
checks "Password Min Days" "14" "${pmin}"

# Check the pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' { print $2 } ' )
checks "Password Warn Age" "7" "${pwarn}"

# Check the SSH UsePam Configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk ' { print $2 } ' )
checks "SSH UsePAM" "yes" "${chkSSHPAM}"

# Check permissions on users home directory
echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' { print $3 } ')
do 
	chDir=$(ls -ld /home/${eachDir} | awk ' { print $1 } ')
	checks "Home directory ${eachDir}" "drwx------" "${chDir}"
done

# Ensure IP forwarding is disabled
ip_forward_chk=$(grep "net\.ipv4\.ip_forward" /etc/sysctl.conf /etc/sysctl.d/*)
checks "IP forwarding" "0" "${ip_forward_chk}" "Edit /etc/sysctl.conf and set: \nnet.ipv4.ip_forward=1\nto\nnet.ipv4.ip_forward=0.\nThen run: \n sysctl -w"

# Ensure ICMP redirects are not accepted
all_accept=$(sysctl net.ipv4.conf.all.accept redirects)
default_accept=$(sysctl net.ipv4.conf.default.accept_redirects)
all_accept_redirects=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf /etc/sysctl.d/*)
default_accept_redirects=$(grep "net\.ipv4\.conf\.default\.accept_redirects" /etc/sysctl.conf /etc/sysctl.d/*)

checks "ICMP Redirects: All Accept" "net.ipv4.conf.all.accept redirects = 0" "${all_accept}" "Set the following parameters in /etc/sysctl.conf or a /etc/sysctl.d/* file:\n net.ipv4.conf.all.accept redirects = 0\nnet.ipv4.conf.default.accept_redirects = 0\nRun the following commands to set the active kernel parameters:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=0"
checks "ICMP Redirects: Default Accept" "net.ipv4.conf.default.accept_redirects = 0" "${default_accept}" "Set the following parameters in /etc/sysctl.conf or a /etc/sysctl.d/* file:\n net.ipv4.conf.all.accept redirects = 0\nnet.ipv4.conf.default.accept_redirects = 0\nRun the following commands to set the active kernel parameters:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=0"
checks "ICMP Redirects: All Accept Redirects" "net.ipv4.conf.all.accept redirects= 0" "${all_accept_redirects}" "Set the following parameters in /etc/sysctl.conf or a /etc/sysctl.d/* file:\n net.ipv4.conf.all.accept redirects = 0\nnet.ipv4.conf.default.accept_redirects = 0\nRun the following commands to set the active kernel parameters:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=0"
checks "ICMP Redirects: Default Accept Redirects" "net.ipv4.conf.default.accept_redirects= 0" "${default_accept_redirects}" "Set the following parameters in /etc/sysctl.conf or a /etc/sysctl.d/* file:\n net.ipv4.conf.all.accept redirects = 0\nnet.ipv4.conf.default.accept_redirects = 0\nRun the following commands to set the active kernel parameters:\nsysctl -w net.ipv4.conf.all.accept redirects=0\nsysctl -w net.ipv4.conf.default.accept redirects=0\nsysctl -w net.ipv4.route.flush=0"

# Ensure permissions on /etc/crontab are configured
crontab=$(stat /etc/crontab | grep "Access: (")
checks "Permissions on /etc/crontab" "Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "${crontab}" "Run the following commands to set ownership and permissions on /etc/crontab:\nchown root:root /etc/crontab\nchmod og-rwx /etc/crontab"

# ensure permissions on /etc/cron.hourly are configured
cron_hourly=$(stat /etc/cron.hourly | grep "Access: (")
checks "Permissions on /etc/cron.hourly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cron_hourly}" "Run the following commands to set ownership and permissions on /etc/cron.hourly:\nchown root:root /etc/cron.hourly\nchmod og-rwx /etc/cron.hourly"

# Ensure permissions on /etc/cron.daily are configured
cron_daily=$(stat /etc/cron.daily | grep "Access: (")
checks "Permissions on /etc/cron.daily" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cron_daily}" "Run the following commands to set ownership and permissions on /etc/cron.daily:\nchown root:root /etc/cron.daily\nchmod og-rwx /etc/cron.daily"

# Ensure permissions on /etc/cron.weekly are configured
cron_weekly=$(stat /etc/cron.weekly |grep "Access: (")
checks "Permissions on /etc/cron.weekly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cron_weeky}" "Run the following commands to set ownership and permissions on /etc/cron.weekly:\nchown root:root /etc/cron.weekly\nchmod og-rwx /etc/cron.weekly"

# Ensure permissions on /etc/cron.monthly are configured
cron_monthly=$(stat /etc/cron.monthly | grep "Access: (")
checks "Permissions on /etc/cron.monthly" "Access: (0700/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cron_monthly}" "Run the following commands to set ownership and permissions on /etc/cron.monthly:\nchown root:root /etc/cron.monthly\nchmod og-rwx /etc/cron.monthly"

# Ensure permissions on /etc/passwd are configured
passwd=$(stat /etc/passwd | grep "Access: (")
checks "Permissions on /etc/passwd" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${passwd}" "Run the vollowig command to set permissions on /etc/passwd:\nchown root:root /etc/passwd\nchmod 644 /etc/passwd"

# Ensure permissions on /etc/shadow are configured
shadow=$(stat /etc/shadow | grep "Access: (")
checks "Permissions on /etc/shadow" "Access: (0644/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${shadow}" "Run one of the following commands to set permissions on /etc/shadow:\nchown root:shadow /etc/shadow\nchmod o-rwx,g-wx /etc/shadow"

# Ensure permissions on /etc/group are configured
group=$(stat /etc/group | grep "Access: (")
checks "Permissions on /etc/group" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${group}" "Run the following commands to set permissions on /etc/group:\nchown root:root /etc/group\nchmod 644 /etc/group"

# Ensure permissions on /etc/gshadow are configured
gshadow=$(stat /etc/gshadow | grep "Access: (")
checks "Permissions on /etc/gshadow" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${gshadow}" "Run the following commands to set permissions on /etc/gshadow:\nchown root:shadow /etc/gshadow\nchmod o-rwx,g-rw,g-rw /etc/gshadow"

# Ensure permissions on /etc/passwd- are configured
passwd_dash=$(stat /etc/passwd- | grep "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)")
checks "Permissions on /etc/shadow-" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${passwd_dash}" "Run one of the following chown commands as appropriate and the chmod to set permissions on /etc/passwd-:\nchown root:root /etc/passwd-\nchmod u-x,go-wx /etc/passwd-"


# Ensure permissions on /etc/shadow- are configured
shadow_dash=$(stat /etc/shadow- | grep "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)")
checks "Permissions on /etc/shadow-" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${shadow_dash}" "Run one of the following chown commands as appropriate and the chmod to set permissions on /etc/shadow-:\nchown root:shadow /etc/shadow-\nchmod o-rwx,g-rw /etc/shadow-"

# Ensure permissions on /etc/group- are configured
group_dash=$(stat /etc/group- | grep "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)")
checks "Permissions on /etc/group-" "Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${group_dash}" "Run one of the following chown commands as appropriate and the chmod to set permissions on /etc/group-:\nchown root:root /etc/group-\nchmod u-x,go-wx /etc/group-"

# Ensure permissions on /etc/gshadow- are configured
gshadow_dash=$(stat /etc/gshadow- | grep "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)")
checks "Permissions on /etc/gshadow-" "Access: (0640/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${gshadow_dash}" "Run one of the following chown commands as appropriate and the chmod to set permissions on /etc/gshadow-:\nchown root:shadow /etc/gshadow-\nchmod o-rxw,g-rw /etc/gshadow-"

# Ensure no legacy "+" entries exist in /etc/passwd
legacy_passwd_chk=$(grep '^+:' /etc/passwd)
checks "Legacy + entries in /etc/group" "" "${legacy_passwd_chk}" "Remove any legacy '+' entries from /etc/passwd if they exist"


# Ensure no legacy "+" entries exist in /etc/shadow
legacy_shadow_chk=$(grep '^+:' /etc/shadow)
checks "Legacy + entries in /etc/shadow" "" "${legacy_shadow_chk}" "Remove any legacy '+' entries from /etc/shadow if they exist"

# Ensure no legacy "+" entries exist in /etc/group
legacy_group_chk=$(grep '^+:' /etc/group)
checks "Legacy + entries in /etc/group" "" "${legacy_group_chk}" "Remove any legacy '+' entries from /etc/group if they exist"

# Ensure root is the only UID 0 account
root_uid_chk=$(cat /etc/passwd | awk -F: '($3 == 0) {print $1} ')
checks "Root UID" "root" "${root_uid_chk}" "Remediation:\n Remove any users other than root with a UID 0 or assign them a new UID if appropriate"