Param(
    [string]$drive = 'C'
)

$driveLetter = $drive + ':'

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
{
    Write-Warning "You need to run this script from an elevated PowerShell prompt.`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning 'Aborting script...'
    Break
}

# Check free space on C: - Minimum for the Hydration Kit is 100 GB
$NeededFreeSpace = '107374182400'
$disk = Get-wmiObject Win32_LogicalDisk -computername . | where-object {$_.DeviceID -eq $driveLetter}

[float]$freespace = $disk.FreeSpace;
$freeSpaceGB = [Math]::Round($freespace / 1073741824);

if($disk.FreeSpace -lt $NeededFreeSpace)
{
Write-Warning 'Oupps, you need at least 100 GB of free disk space'
Write-Warning "Available free space on $driveLetter is $freeSpaceGB GB"
Write-Warning 'Aborting script...'
Break
}

# Validation OK, create Hydration Deployment Share
$MDTServer = (get-wmiobject win32_computersystem).Name

Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue
$DSRoot = $driveLetter + '\HydrationConfigMgr\DS'
$DSISORoot = $driveLetter + '\HydrationConfigMgr\ISO'
mkdir $DSRoot
New-PSDrive -Name 'DS001' -PSProvider 'MDTProvider' -Root $DSRoot -Description 'MoL ConfigMgr' -NetworkPath "\\$MDTServer\MoLConfigMgr$" -Verbose | Add-MDTPersistentDrive -Verbose

mkdir $DSISORoot\Content\Deploy
new-item -path 'DS001:\Media' -enable 'True' -Name 'MEDIA001' -Comments '' -Root $DSISORoot -SelectionProfile 'Everything' -SupportX86 'False' -SupportX64 'True' -GenerateISO 'True' -ISOName 'MoLConfigMgr.iso' -Verbose
new-PSDrive -Name 'MEDIA001' -PSProvider 'MDTProvider' -Root $DSISORoot\Content\Deploy -Description 'MoL ConfigMgr Media' -Force -Verbose

# Copy sample files to Hydration Deployment Share
Copy-Item -Path '.\Hydration\Applications' -Destination $DSRoot -Recurse -Verbose -Force
Copy-Item -Path '.\Hydration\Control' -Destination $DSRoot -Recurse -Verbose -Force
Copy-Item -Path '.\Hydration\Operating Systems' -Destination $DSRoot -Recurse -Verbose -Force
Copy-Item -Path '.\Hydration\Scripts' -Destination $DSRoot -Recurse -Verbose -Force
Copy-Item -Path '.\Media\Control' -Destination $DSISORoot\Content\Deploy -Recurse -Verbose -Force
