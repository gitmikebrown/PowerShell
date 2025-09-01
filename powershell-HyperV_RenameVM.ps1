<#
UNTESTED

.SYNOPSIS
    Renames a Hyper-V VM and all related assets (VM name, VHDs, config files).

.DESCRIPTION
    This script performs a full rename operation for a Hyper-V VM:
    - Renames the VM object
    - Exports the VM to a specified path
    - Renames associated VHD files
    - Imports the VM with a new ID
    - Reattaches renamed VHDs

.NOTES
    Author: Mike's AI Copilot
    Designed for clarity, safety, and future-proofing
    Requires Administrator privileges
#>

function Rename-HyperVVM {
    param (
        [string]$OldVMName,
        [string]$NewVMName,
        [string]$ExportPath = "C:\VMExports\$NewVMName"
    )

    # Step 1: Validate that the original VM exists
    if (-not (Get-VM -Name $OldVMName -ErrorAction SilentlyContinue)) {
        Write-Warning "VM '$OldVMName' not found. Aborting."
        return
    }

    Write-Host "`n[1] Renaming VM object..." -ForegroundColor Cyan
    Rename-VM -Name $OldVMName -NewName $NewVMName

    # Step 2: Export the renamed VM to a temporary folder
    Write-Host "[2] Exporting VM to $ExportPath..." -ForegroundColor Cyan
    Export-VM -Name $NewVMName -Path $ExportPath

    # Step 3: Rename VHD files to match the new VM name
    Write-Host "[3] Renaming VHDs..." -ForegroundColor Cyan
    $vhdPath = Join-Path $ExportPath "Virtual Hard Disks"
    Get-ChildItem $vhdPath -Filter "$OldVMName*.vhdx" | ForEach-Object {
        $newName = $_.Name -replace [regex]::Escape($OldVMName), $NewVMName
        Rename-Item $_.FullName (Join-Path $vhdPath $newName)
    }

    # Step 4: Import the VM using the exported config, generating a new ID
    Write-Host "[4] Importing VM with new ID..." -ForegroundColor Cyan
    $vmConfigPath = Get-ChildItem "$ExportPath\Virtual Machines" -Filter *.xml | Select-Object -First 1
    $importedVM = Import-VM -Path $vmConfigPath.FullName -Copy -GenerateNewId

    # Step 5: Reattach the renamed VHD to the new VM
    Write-Host "[5] Reattaching renamed VHDs..." -ForegroundColor Cyan
    $newVHD = Get-ChildItem $vhdPath -Filter "$NewVMName*.vhdx" | Select-Object -First 1
    Set-VMHardDiskDrive -VMName $NewVMName -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0 -Path $newVHD.FullName

    Write-Host "`n✅ VM '$OldVMName' successfully renamed to '$NewVMName' and reconfigured." -ForegroundColor Green
}

# === Menu-driven prompt ===
Write-Host "=== Hyper-V VM Rename Toolkit ===" -ForegroundColor Yellow
$oldName = Read-Host "Enter the current VM name"
$newName = Read-Host "Enter the new VM name"
Rename-HyperVVM -OldVMName $oldName -NewVMName $newName