# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Error 'Please run this script as an Administrator!'
    exit
}

# Check if Hyper-V is supported on this machine
$hyperVCheck = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V

# Function to enable Hyper-V
function Enable-HyperV {
    Write-Host 'Enabling Hyper-V features...'
    # Enabling Hyper-V Management Tools and Hyper-V Platform
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'Hyper-V has been successfully enabled. You may need to restart your computer.'
    } else {
        Write-Host "Failed to enable Hyper-V. Error code: $LASTEXITCODE"
    }
}

# Check current state and act accordingly
switch ($hyperVCheck.State) {
    'Enabled' {
        Write-Host 'Hyper-V is already enabled on this system.'
    }
    'Disabled' {
        Enable-HyperV
    }
    default {
        Write-Host 'Hyper-V feature is not available on this system or cannot be confirmed.'
    }
}

# Import Hyper-V module if not already loaded
if (-not (Get-Module -Name Hyper-V)) {
    Import-Module -Name Hyper-V
}

# Check current configuration of Hyper-V default path
$currentDiskPath = (Get-VMHost).VirtualHardDiskPath

# Set the new path for Hyper-V storage if not already set
$NewPath = 'E:\Hyper-V\'

if ($currentDiskPath -ne $NewPath) {
    Write-Host "Current Hyper-V storage path is '$currentDiskPath'. Changing it to '$NewPath'."
    # Set the new default path for Hyper-V virtual hard disks
    Set-VMHost -VirtualHardDiskPath $NewPath -VirtualMachinePath $NewPath

    if ($?) {
        Write-Host "Hyper-V storage path successfully changed to '$NewPath'."
    } else {
        Write-Error 'Failed to change Hyper-V storage path.'
    }
} else {
    Write-Host "Hyper-V storage path is already set to '$NewPath'. No changes are needed."
}
