# Use the Get-WMIobject cmdlet
# Get-WmiObject -Class Win32_Service | select Name, PathName, ProcessId
# Get-WmiObject -List | where { $_.Name -ilike "Win32_[n-z]*" } | Sort-Object 
# Get-WmiObject -Class Win32_Account | Get-Member

# Task: Grab the network adapter information using the WMI class
Get-WmiObject -Class Win32_NetworkAdapter

# Get the IP address, default gateway, and the DNS Servers
# Bonus: Get the DHCP server.
Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select-Object IPAddress, DefaultIPGateway, DNSDomain, DHCPServer
 
# Running your code using a screen recorder