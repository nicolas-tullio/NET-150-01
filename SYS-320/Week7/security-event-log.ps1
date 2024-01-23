# Storyline: Review the Security Event Log

# Directory to save files:
$myDir = "C:\Users\nico\Documents\Automation\Powershell\"

# List all the available Windows Event logs
Get-EventLog -List

# Create a prompt to allow user to select the log to view
$readLog = Read-Host -Prompt "Please select a log to review from the list above"

# Task: Create a prompt that allows a user to specify a keyword or phrase to search on.
# Find a string from your event logs to search on
Get-EventLog -LogName $readLog -Newest 40 | Sort-Object EventID -Unique | Format-Table EventID, Message 
$readPhrase = Read-Host -Prompt "Please specify a keyword or phrase to search"

# Print the results for that log
Get-EventLog -LogName $readLog -Newest 40 | Where-Object { $_.Message -ilike "*$readPhrase*" } | Export-Csv -NoTypeInformation `
-Path "$myDir\securityLogs.csv"