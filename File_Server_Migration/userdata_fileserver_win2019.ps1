<powershell>
# ---------------------------
# Install File Server role
# ---------------------------
Install-WindowsFeature FS-FileServer -IncludeManagementTools

Start-Sleep -Seconds 15

# ---------------------------
# Initialize the new data disk (RAW) and assign D:
# ---------------------------
$rawDisk = Get-Disk | Where-Object PartitionStyle -Eq 'RAW' | Select-Object -First 1

if ($null -ne $rawDisk) {
    Initialize-Disk -Number $rawDisk.Number -PartitionStyle GPT -PassThru | Out-Null

    # Create a partition using all space and force drive letter D
    $partition = New-Partition -DiskNumber $rawDisk.Number -UseMaximumSize -DriveLetter D

    # Format volume
    Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "FileShareData" -Confirm:$false
} else {
    # If disk is already initialized or not detected, ensure D exists
    if (-not (Test-Path "D:\")) {
        Write-Output "No RAW disk found and D: does not exist. Skipping disk setup."
    }
}

# ---------------------------
# Create share folder on D:
# ---------------------------
$shareRoot = "D:\Shares\Public"
if (-not (Test-Path "D:\")) {
  # fallback (should not happen if data disk is created correctly)
  $shareRoot = "C:\Shares\Public"
}

New-Item -Path $shareRoot -ItemType Directory -Force | Out-Null

# ---------------------------
# Create SMB share
# ---------------------------
$shareName = "Public"

if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $shareName -Path $shareRoot -FullAccess "Everyone"
}

</powershell>