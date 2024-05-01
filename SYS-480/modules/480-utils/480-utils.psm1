function 480Banner() {
    Write-Host "`nHello SYS480`n"
}
function 480Connect([string] $server) {
    $connection = $global:DefaultVIServer
    # are we already connected?
    if ($connection) {
        $msg = "Already Connected to: {0}" -f $connection

        Write-Host -ForegroundColor Green $msg
    }
    else {
        $connection = Connect-VIServer -Server $server 
    }
}
function Get-480Config([string] $config_path) {
    Write-Host "Reading" $config_path
    $conf = $null
    if (Test-Path $config_path) {
        $conf = (Get-Content -Path $config_path -Raw | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor Green $msg
    }
    else {
        Write-Host "No configuration found at $config_path" -ForegroundColor Yellow
    }
    return $conf
}
function Select-VM([string] $folder) {
    $selected_vm = $null
    try {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach ($vm in $vms) {
            Write-Host [$index] $vm.name
            $index += 1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_vm = $vms[$pick_index - 1]
        Write-Host "You picked " $selected_vm.name
        return $selected_vm
    }
    catch {
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
}

function LinkedClone($conf) {
    try {
        Get-VM -Location $conf.vm_folder | Select-Object Name -ExpandProperty Name
        try {
            $toclone = Get-VM -Name (Read-Host -Prompt "Choose a VM to clone") -ErrorAction Stop
            try {
                $snapshot = Get-Snapshot -VM $toclone -Name $conf.snapshot
                $clonename = Read-Host -Prompt "Enter a name for the new VM"
                $linkedname = "{0}.linked" -f $clonename
                try {
                    $linkedvm = New-VM -LinkedClone -Name $linkedname -VM $toclone -ReferenceSnapshot $snapshot -VMHost $conf.esxi_host -Datastore $conf.datastore
                    $fullClone = Read-Host -Prompt "Do you want to create a full clone? (yes/no)"
                    if ($fullClone -eq "yes") {
                        try {
                            $newvm = New-VM -Name $clonename -VM $linkedvm -VMHost $conf.esxi_host -Datastore $conf.datastore
                            try {
                                $newvm | New-Snapshot -Name "Base" 
                                try {
                                    $linkedvm | Remove-VM -DeletePermanently -Confirm:$false
                                    Write-Host "Clone created at $conf.datastore named $clonename." -ForegroundColor Green
                                }
                                catch {
                                    Write-Host "An error occurred while deleting the linked VM: $_" -ForegroundColor Red
                                }
                            }
                            catch {
                                Write-Host "An error occurred while creating the new Base snapshot: $_" -ForegroundColor Red
                            }
                        }
                        catch {
                            Write-Host "An error occurred while creating the new VM: $_" -ForegroundColor Red
                        }
                    }
                    else {
                        Write-Host "Ending process as per user request." -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "An error occurred while creating the linked clone: $_" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "An error occurred while getting the snapshot: $_" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "An error occurred while getting the VM to clone: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "An error occurred while getting the VM list: $_" -ForegroundColor Red
    }
}


function New-Network($conf) {
    try {
        # Prompt the user for the new switch name
        $switchName = Read-Host -Prompt "Enter the new Virtual Switch name"

        # Create the switch
        $vswitch = New-VirtualSwitch -VMHost $conf.esxi_host -Name $switchName -ErrorAction Stop
        Write-Host ("Created Virtual Switch {0}" -f $vswitch.Name) -ForegroundColor Green

        try {
            # Prompt the user for the new port group name
            $portGroupName = Read-Host -Prompt "Enter the new Port Group name"

            # Create the port group
            $vport = New-VirtualPortGroup -Name $portGroupName -VirtualSwitch $vswitch -ErrorAction Stop
            Write-Host ("Created Virtual Port Group {0}" -f $vport.Name) -ForegroundColor Green
        } 
        catch {
            Write-Host "Port Group creation failed. Error: $_" -ForegroundColor Red
        }
    } 
    catch {
        Write-Host "Virtual Switch creation failed. Error: $_" -ForegroundColor Red
    }
}

function Get-IP ($conf) {
    try {
        Get-VM | Select-Object Name -ExpandProperty Name
        $vm = Get-VM -Name (Read-Host -Prompt "`nChoose a VM") -ErrorAction Stop
        $ip = (Get-VM -Name $vm).Guest.IPAddress[0]
        $mac = (Get-NetworkAdapter -VM $vm | Select-Object MacAddress).MacAddress
        $output = "
Name: $vm 
IP: $ip
MAC: $mac
        "
        Write-Host $output
    }
    catch {
        Write-Host "An error occurred: $_"
    }
}

function Set-Power($conf) {
    try {
        Get-VM | Select-Object Name -ExpandProperty Name
        try {
            $vm = Get-VM -Name (Read-Host -Prompt "`nChoose a VM to manage") -ErrorAction Stop
            $action = Read-Host -Prompt "`nWould you like to start or stop the VM? (Enter 'start' or 'stop')"
            if ($action -eq "start") {
                try {
                    Start-VM -VM $vm -Confirm:$false
                    Write-Host "VM $vm started successfully." -ForegroundColor Green
                }
                catch {
                    Write-Host "An error occurred while starting the VM: $_" -ForegroundColor Red
                }
            }
            elseif ($action -eq "stop") {
                try {
                    Stop-VM -VM $vm -Confirm:$false
                    Write-Host "VM $vm stopped successfully." -ForegroundColor Green
                }
                catch {
                    Write-Host "An error occurred while stopping the VM: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Invalid action. Please enter 'start' or 'stop'." -ForegroundColor Red
            }
        }
        catch {
            Write-Host "An error occurred while selecting the VM: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "An error occurred while getting the VM list: $_" -ForegroundColor Red
    }
}

function Set-Network($conf) {
    try {
        Get-VM | Select-Object Name -ExpandProperty Name
        try {
            $vm = Get-VM -Name (Read-Host -Prompt "`nChoose a VM to change a Network adapter on") -ErrorAction Stop
            Get-VirtualNetwork
            $network = Read-Host -Prompt "`nSelect a Network"
            Write-Host ""
            Get-NetworkAdapter -VM $vm | Select-Object Name -ExpandProperty Name
            $adapterName = Read-Host -Prompt "`nSelect a Network Adapter"
            try {
                Get-VM $vm | Get-NetworkAdapter -Name $adapterName | Set-NetworkAdapter -NetworkName $network -Confirm:$false
                Write-Host "Network adapter on $vm changed successfully to $network." -ForegroundColor Green
            }
            catch {
                Write-Host "An error occurred while changing the network adapter: $_" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "An error occurred while selecting the VM: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "An error occurred while getting the VM list: $_" -ForegroundColor Red
    }
}