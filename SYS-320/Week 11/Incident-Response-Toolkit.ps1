# Storyline: A script that provides relevant machine information for incident response. 

# Create a prompt that asks the user for the location of where to save the results.
# This variable will be used to construct the locations for each file saved.
$resultsLoc = Read-Host -Prompt "Enter the location you want the results for the commands to be saved (Ex: C:\Users\champuser\Desktop)"

# The file that will be used to store the checksums created by each file being hashed
$checkLoc = $resultsLoc + "\checksums.txt"
New-Item $checkLoc | Out-Null

# Function to retrieve the artifacts, output to csv, and hash the outputs. 
function getArtifacts() {

    # 1. Running Processes and the path for each process.
    $procLoc = $resultsLoc + "\processes.csv"
    Get-Process | Select-Object ProcessName, Path, ID | Export-Csv -Path $procLoc -NoTypeInformation
    #add the checksum of the newly created file to the array
    $procSum = Get-FileHash -Path $procLoc
    Add-Content $checkLoc ($procSum.Hash + ' ' + $procSum.Path)

    # 2. All registered services and the path to the executable controlling the service (you'll need to use WMI).
    $servLoc = $resultsLoc + "\services.csv"
    Get-WmiObject win32_service | Select-Object Name, PathName | Export-Csv -Path $servLoc -NoTypeInformation
    $servSum = Get-FileHash -Path $servLoc
    Add-Content $checkLoc ($servSum.Hash + ' ' + $servSum.Path)

    # 3. All TCP network sockets
    $tcpLoc = $resultsLoc + "\tcpSockets.csv"
    Get-NetIPConfiguration | Export-Csv -Path $tcpLoc -NoTypeInformation
    $tcpSum = Get-FileHash -Path $tcpLoc
    Add-Content $checkLoc ($tcpSum.Hash + ' ' + $tcpSum.Path)

    # 4. All user account information (you'll need to use WMI)
    $userLoc = $resultsLoc + "\userInfo.csv"
    Get-WmiObject -Class Win32_UserAccount | Export-Csv -Path $userLoc -NoTypeInformation
    $userSum = Get-FileHash -Path $userLoc
    Add-Content $checkLoc ($userSum.Hash + ' ' + $userSum.Path)

    # 5. All NetworkAdapterConfiguration information.
    $netadLoc = $resultsLoc + "\netAdapterConfig.csv"
    Get-WmiObject -Class win32_NetworkAdapterConfiguration | Export-Csv -Path $netadLoc -NoTypeInformation
    $netadSum = Get-FileHash -Path $netadLoc
    Add-Content $checkLoc ($netadSum.Hash + ' ' + $netadSum.Path)

    # 6. Use Powershell cmdlets to save 4 other artifacts that would be useful in an incident but only use Powershell cmdlets.  
    # In your code comment, explain why you selected those four cmdlets and the value it would provide for an incident investigation.

    # 1. Get security logs with Get-EventLog. This is helpful in IR to investigate attempeted and successful account, access, policy, etc. changes.
    # -newest 50 is used to lessen output for the test.
    # This number can be changed if the program was being used in a real-life scenario. 
    $secLogLoc = $resultsLoc + "\secLogs.csv"
    Get-EventLog -LogName "Security" -Newest 50 | Export-Csv -Path $secLogLoc -NoTypeInformation
    $secLogSum = Get-FileHash -Path $secLogLoc
    Add-Content $checkLoc ($secLogSum.Hash + ' ' + $secLogSum.Path)

    # 2. Get registry entries with Get-ItemProperty. THis is helpful in IR to find potentially suspicious registry entries.
    # Remove-ItemProperty can be used for removing suspicious/harmful or persistent registry entries. 
    $regLoc = $resultsLoc + "\regEntries.csv"
    Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion | Export-Csv -Path $regLoc -NoTypeInformation
    $regSum = Get-FileHash -Path $regLoc
    Add-Content $checkLoc ($regSum.Hash + ' ' + $regSum.Path)

    # 3. Get relevant core system information like OS, BIOS, Windows info with Get-ComputerInfo. This is useful to gather a baseline knowledge about
    # the system and to determine any compromises in software and firmware to look for potential attack vectors.
    $sysLoc = $resultsLoc + "\systemInfo.csv"
    Get-ComputerInfo | Export-Csv -Path $sysLoc -NoTypeInformation
    $sysSum = Get-FileHash -Path $sysLoc
    Add-Content $checkLoc ($sysSum.Hash + ' ' + $sysSum.Path)

    # 4. Get a list of local users using Get-LocalUser cmdlet. This is useful to ensure that no unauthorized local (admin) accounts have been created.
    $accLoc = $resultsLoc + "\localAccounts.csv"
    Get-LocalUser | Export-Csv -Path $accLoc -NoTypeInformation
    $accSum = Get-FileHash -Path $accLoc
    Add-Content $checkLoc ($accSum.Hash + ' ' + $accSum.Path)

}

# Function to zip output files and checksums
function zipFiles() {

    #Zip directory with checksums and create a checksum of that file
    $readZip = Read-Host -Prompt "Enter the directory you want the zipped file to be saved to (Ex: C:\Users\champuser\Desktop). Note: This must be a different directory than the one from above."
    $zipLoc = $readZip + "\incidentResponseFiles.zip"

    #Parameters for file compression and compression of the files
    $compress = @{

        Path             = $resultsLoc
        CompressionLevel = "Fastest"
        DestinationPath  = $zipLoc

    }

    Compress-Archive @compress -Force

    #Creation of file to store the hash of the zip file and the process of putting the hash into that file
    $zipTxt = $readZip + "\zip_checksum.txt"
    New-Item $zipTxt | Out-Null
    $zipSum = Get-FileHash -Path $zipLoc
    Add-Content $zipTxt ($zipSum.Hash + ' ' + $zipSum.Path)
    
}

# Call functions to get artifact info and zip when completed
getArtifacts
zipFiles