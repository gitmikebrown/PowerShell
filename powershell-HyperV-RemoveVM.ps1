<#
DO NOT RUN THIS.  IT NEEDS WORK STILL

.SYNOPSIS
    Safely removes a Hyper-V virtual machine and its associated files.

.DESCRIPTION
    This function deletes a VM from Hyper-V, removes its virtual hard disk (VHDX),
    and deletes the VM folder. It's intended for test environments where VMs are
    disposable and can be recreated quickly.

    To use this script:
    1. Save it as a .ps1 file (e.g., Remove-TestVM.ps1)
    2. Dot-source it in your PowerShell session: . .\Remove-VM.ps1
    3. Call the function: Remove-VM -vmName "MyVM" -vmPath "C:\Hyper-V\MyVM"

.NOTES
    - This script does NOT log actions or prompt for confirmation.
    - It assumes the VM folder contains a VHDX file named after the VM.
    - Customize paths and names as needed for your environment.
#>

function Remove-VM {
    param (
        [Parameter(Mandatory = $true)]
        [string]$vmName,

        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$vmPath
    )

    $vhdPath = Join-Path $vmPath "$vmName.vhdx"
    $vmExists = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    $vhdExists = Test-Path $vhdPath
    $folderExists = Test-Path $vmPath

    # Step 1: Scan and summarize
    Write-Host "`n🔍 Scanning for VM components..."
    Write-Host "VM Name: $vmName"
    Write-Host "VM Path: $vmPath"
    Write-Host "VHDX Path: $vhdPath"
    Write-Host "`n✅ Found:"
    if ($vmExists) { Write-Host "• VM '$vmName' is registered in Hyper-V" }
    else { Write-Host "• ❌ VM '$vmName' not found in Hyper-V" }

    if ($vhdExists) {
        Write-Host "• VHDX file exists: $vhdPath"
    } else {
        Write-Host "• ❌ VHDX file not found — will not be deleted"
    }

    if ($folderExists) {
        Write-Host "• VM folder exists: $vmPath"
        if ($folderIsShared) {
            Write-Host "`n⚠️ The folder appears to be shared with other VMs or disks."
            Write-Host "Only the VM registration will be removed unless you explicitly confirm folder deletion."
        }
    } else {
        Write-Host "• ❌ VM folder not found"
    }

    $confirmation = Read-Host "`nDo you want to proceed with deletion of the VM and any safe-to-delete items? (Y/N)"
    if ($confirmation -notin @("Y", "y")) {
        Write-Host "🛑 Operation cancelled by user."
        return
    }

    # Step 3: Begin cleanup
    Write-Host "`n🚧 Starting cleanup..."

    if ($vmExists) {
        Remove-VM -Name $vmName -Force
        Write-Host "✅ VM '$vmName' removed from Hyper-V."
    }

    if ($vhdExists) {
        try {
            Remove-Item $vhdPath -Force
            Write-Host "🗑️ VHDX file deleted: $vhdPath"
        } catch {
            Write-Host "⚠️ Failed to delete VHDX: $($_.Exception.Message)"
        }
    }

    if ($folderExists) {
        # Check for other VHDX or VM config files
        $otherVHDs = Get-ChildItem -Path $vmPath -Filter *.vhdx | Where-Object { $_.Name -ne "$vmName.vhdx" }
        $otherVMConfigs = Get-ChildItem -Path $vmPath -Filter *.vmcx | Where-Object { $_.Name -notlike "$vmName*" }
        $folderIsShared = ($otherVHDs.Count -gt 0 -or $otherVMConfigs.Count -gt 0)

        if ($folderIsShared) {
            Write-Host "⚠️ VM folder appears to be shared with other VMs or disks."
            $folderConfirm = Read-Host "Do you still want to delete the entire folder '$vmPath'? (Y/N)"
            if ($folderConfirm -notin @("Y", "y")) {
                Write-Host "🛑 Skipping folder deletion to avoid affecting other VMs."
            } else {
                try {
                    Remove-Item $vmPath -Recurse -Force
                    Write-Host "🧹 Shared folder deleted as confirmed."
                } catch {
                    Write-Host "⚠️ Folder deletion failed. Attempting to release file locks..."
                    Stop-Service vmms
                    Start-Sleep -Seconds 2
                    Remove-Item $vmPath -Recurse -Force
                    Start-Service vmms
                    Write-Host "✅ Folder deleted after releasing lock."
                }
            }
        } else {
            try {
                Remove-Item $vmPath -Recurse -Force
                Write-Host "🧹 Dedicated VM folder deleted: $vmPath"
            } catch {
                Write-Host "⚠️ Folder deletion failed. Attempting to release file locks..."
                Stop-Service vmms
                Start-Sleep -Seconds 2
                Remove-Item $vmPath -Recurse -Force
                Start-Service vmms
                Write-Host "✅ Folder deleted after releasing lock."
            }
        }
    }

    Write-Host "`n✅ Cleanup complete."
}