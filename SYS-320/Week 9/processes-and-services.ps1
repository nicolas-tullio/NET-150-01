# Storyline: Using the Get-Process and Get-Service
# Get-Process | Select-Object ProcessName, Path, ID | `
# Export-Csv -Path "C:\Users\mpaga\Desktop\myProcesses.csv" -NoTypeInformation
# Get-Process | Get-Member
# Get-Service | Where { $_.Status  -eq "Stopped" }


Get-Process | Select-Object ProcessName, Path, ID | `
Export-Csv -Path "C:\Users\nico\Documents\Automation\Powershell\processes.csv" -NoTypeInformation

Get-Service | Where-Object { $_.Status -eq "Running"} | `
Export-Csv -Path "C:\Users\nico\Documents\Automation\Powershell\running_services.csv" -NoTypeInformation