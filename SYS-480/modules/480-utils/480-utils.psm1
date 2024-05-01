function 480Banner() {
    Write-Host "Hello SYS480"
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
            $toclone = Get-VM -Name (Read-Host -Prompt "VM to Clone") -ErrorAction Stop
            try {
                $snapshot = Get-Snapshot -VM $toclone -Name $conf.snapshot
                $clonename = Read-Host -Prompt "Enter a name for the new VM"
                $linkedname = "{0}.linked" -f $clonename
                try {
                    $linkedvm = New-VM -LinkedClone -Name $linkedname -VM $toclone -ReferenceSnapshot $snapshot -VMHost $conf.esxi_host -Datastore $conf.datastore
                    try {
                        $newvm = New-VM -Name $clonename -VM $linkedvm -VMHost $conf.esxi_host -Datastore $conf.datastore
                        try {
                            $newvm | New-Snapshot -Name "Base" 
                            try {
                                $linkedvm | Remove-VM -DeletePermanently -Confirm:$false
                                Write-Host "Clone created at $datastore named $clonename." -ForegroundColor Green
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