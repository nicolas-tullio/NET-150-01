# Array of websites containing threat intell
$drop_urls = @('https://rules.emergingthreats.net/blockrules/emerging-botcc.rules', 'https://rules.emergingthreats.net/blockrules/compromised-ips.txt')

# Loop through the URLS for the list
foreach ($u in $drop_urls) {

    # Extract the filename
    $temp = $u.Split("/")

    # The last element in the array plucked off is the filename
    $file_name = $temp[4]

    if (Test-Path $file_name) {

        continue

    }
    else {

        # Download the rules list
        Invoke-WebRequest -Uri $u -OutFile $file_name

    } # close if statement

} # close the foreach loop

# Array containing the filename
$input_paths = @('.\compromised-ips.txt', '.\emerging-botcc.rules')

# Extract the IP addresses.
# 108.190.109.107
# 108.191.2.72
$regex_drop = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

# Append the IP addresses to the temporary IP list.
select-string -Path $input_paths -Pattern $regex_drop | `
    ForEach-Object { $_.Matches } | `
    ForEach-Object { $_.Value } | Sort-Object | Get-unique | `
    Out-File -Filepath "ips-bad.tmp"

# Get the IP addresses discovered, loop through and replace the beginning of the line with the IPTab1es syntax
# After the IP address, add the remaining IPTab1es syntax and save the results to a file.
# iptables -A INPUT -s 108.191.2.72 -j DROP

$firewall = Read-Host "Choose firewall: [I]PTables or [W]indows Firewall"

switch ($firewall) {
    'I' {
(Get-Content -Path ".\ips-bad.tmp") | ForEach-Object `
        { $_ -replace "^", "iptables -A INPUT -s " -replace "$", " -j DROP" } | `
            Out-File -FilePath "iptables.bash"
    }
    'W' {
(Get-Content -Path ".\ips-bad.tmp") | ForEach-Object `
        { $_ -replace "^", 'netsh advfirewall firewall add rule name="BLACKLIST" dir=in action=block remoteip=' } | `
            Out-File -FilePath "firewall.ps1"
    }
}