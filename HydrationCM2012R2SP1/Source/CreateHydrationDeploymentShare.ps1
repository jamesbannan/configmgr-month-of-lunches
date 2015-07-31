# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    Break
}

# Check Windows Version
$OSCaption = (Get-WmiObject win32_operatingsystem).caption
If ($OSCaption -like "Microsoft Windows 10*")
{
    Write-Warning "Oupps, MDT 2013 with Windows ADK 8.1 does not work correctly on Windows 10."
    Write-Warning "For now, you really need to use Windows 7/8/81 or Windows Server 2008R2/2012/2012R2."
    Write-Warning "Aborting script..."
    Break
}


# Check free space on C: - Minimum for the Hydration Kit is 100 GB
$NeededFreeSpace = "107374182400"
$disk = Get-wmiObject Win32_LogicalDisk -computername . | where-object {$_.DeviceID -eq "C:"} 

[float]$freespace = $disk.FreeSpace;
$freeSpaceGB = [Math]::Round($freespace / 1073741824);

if($disk.FreeSpace -lt $NeededFreeSpace)
{
Write-Warning "Oupps, you need at least 100 GB of free disk space"
Write-Warning "Available free space on C: is $freeSpaceGB GB"
Write-Warning "Aborting script..."
Break
}

# Validation OK, create Hydration Deployment Share
$MDTServer = (get-wmiobject win32_computersystem).Name

Add-PSSnapIn Microsoft.BDD.PSSnapIn -ErrorAction SilentlyContinue 
md C:\HydrationCM2012R2SP1\DS
new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "C:\HydrationCM2012R2SP1\DS" -Description "Hydration CM2012 R2" -NetworkPath "\\$MDTServer\HydrationSC2012R2$" -Verbose | add-MDTPersistentDrive -Verbose

md C:\HydrationCM2012R2SP1\ISO\Content\Deploy
new-item -path "DS001:\Media" -enable "True" -Name "MEDIA001" -Comments "" -Root "C:\HydrationCM2012R2SP1\ISO" -SelectionProfile "Everything" -SupportX86 "False" -SupportX64 "True" -GenerateISO "True" -ISOName "HydrationCM2012R2SP1.iso" -Verbose
new-PSDrive -Name "MEDIA001" -PSProvider "MDTProvider" -Root "C:\HydrationCM2012R2SP1\ISO\Content\Deploy" -Description "Hydration CM2012 R2 SP1 Media" -Force -Verbose

# Copy sample files to Hydration Deployment Share
Copy-Item -Path "C:\HydrationCM2012R2SP1\Source\Hydration\Applications" -Destination "C:\HydrationCM2012R2SP1\DS" -Recurse -Verbose -Force
Copy-Item -Path "C:\HydrationCM2012R2SP1\Source\Hydration\Control" -Destination "C:\HydrationCM2012R2SP1\DS" -Recurse -Verbose -Force
Copy-Item -Path "C:\HydrationCM2012R2SP1\Source\Hydration\Operating Systems" -Destination "C:\HydrationCM2012R2SP1\DS" -Recurse -Verbose -Force
Copy-Item -Path "C:\HydrationCM2012R2SP1\Source\Hydration\Scripts" -Destination "C:\HydrationCM2012R2SP1\DS" -Recurse -Verbose -Force
Copy-Item -Path "C:\HydrationCM2012R2SP1\Source\Media\Control" -Destination "C:\HydrationCM2012R2SP1\ISO\Content\Deploy" -Recurse -Verbose -Force
