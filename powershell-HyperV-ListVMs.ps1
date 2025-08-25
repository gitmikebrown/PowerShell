<#
.SYNOPSIS
    Menu-driven toolkit for managing Hyper-V virtual machines.

.DESCRIPTION
    Provides an interactive CLI menu to list VMs, view paths, start/stop VMs, and more.
    Designed for safe handoff and future-proofing with clear prompts and validation.

.NOTES
    - Requires Hyper-V and admin privileges.
    - Easily extendable with new menu items.
#>

function Show-Menu {
    Clear-Host
    Write-Host "Hyper-V VM Toolkit"
    Write-Host "==================="
    Write-Host "1. List all registered VMs"
    Write-Host "2. Show VM paths"
    Write-Host "3. Start a VM"
    Write-Host "4. Stop a VM"
    Write-Host "5. Exit"
    Write-Host ""
}

function Pause {
    Write-Host "`nPress Enter to continue..."
    [void][System.Console]::ReadLine()
}

function List-VMs {
    $vms = Get-VM
    if ($vms.Count -eq 0) {
        Write-Host "No VMs found."
    } else {
        $vms | Format-Table Name, State, MemoryStartup, Generation -AutoSize
    }
    Pause
}

function Show-VMPaths {
    $vms = Get-VM
    foreach ($vm in $vms) {
        $vhdPaths = (Get-VMHardDiskDrive -VMName $vm.Name).Path -join "`n            "
        Write-Host "`nName: $($vm.Name)"
        Write-Host "  State:          $($vm.State)"
        Write-Host "  Memory:         $($vm.MemoryStartup) MB"
        Write-Host "  Generation:     $($vm.Generation)"
        Write-Host "  Config Path:    $($vm.ConfigurationLocation)"
        Write-Host "  VHD Path(s):    $vhdPaths"
        Write-Host "---------------------------------------------"
    }
    Pause
}

function Select-VMByNumber {
    $vms = Get-VM
    if ($vms.Count -eq 0) {
        Write-Host "No VMs found." -ForegroundColor Yellow
        return $null
    }

    Write-Host "`nAvailable VMs:"
    for ($i = 0; $i -lt $vms.Count; $i++) {
        Write-Host "$($i + 1). $($vms[$i].Name) [$($vms[$i].State)]"
    }

    $selection = Read-Host "`nEnter the number of the VM"
    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $vms.Count) {
        return $vms[$selection - 1].Name
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
        return $null
    }
}

function Start-VMInteractive {
    $vmName = Select-VMByNumber
    if ($vmName) {
        try {
            Start-VM -Name $vmName -ErrorAction Stop
            Write-Host "VM '$vmName' started." -ForegroundColor Green
        } catch {
            Write-Host "Failed to start VM '$vmName': $_" -ForegroundColor Red
        }
    }
    Pause
}

function Stop-VMInteractive {
    $vmName = Select-VMByNumber
    if ($vmName) {
        try {
            Stop-VM -Name $vmName -Force -ErrorAction Stop
            Write-Host "VM '$vmName' stopped." -ForegroundColor Green
        } catch {
            Write-Host "Failed to stop VM '$vmName': $_" -ForegroundColor Red
        }
    }
    Pause
}

# Main loop
do {
    Show-Menu
    $choice = Read-Host "Select an option (1-5)"
    switch ($choice) {
        "1" { List-VMs }
        "2" { Show-VMPaths }
        "3" { Start-VMInteractive }
        "4" { Stop-VMInteractive }
        "5" { Write-Host "Exiting..."; break }
        default { Write-Host "Invalid selection."; Pause }
    }
} while ($true)