Clear-Host
Import-Module 'Posh-SSH'
# Storyline: Login to a remote SSH server
New-SSHSession -ComputerName '192.168.87.128' -Credential (Get-Credential nicolas)

while ($true) {

    # Add a prompt to run commands
    $the_cmd = Read-Host -Prompt "Please enter a command"

    # Run command on remote SSH server
    (Invoke-SSHCommand -index 0 $the_cmd).Output

}

# Set-SCPFile -ComputerName '192.168.87.128' -Credential (Get-Credential nicolas) `
# -RemotePath '/home/nicolas' -LocalFile '.\test.txt'

# Remove-SSHSession -SessionId 0