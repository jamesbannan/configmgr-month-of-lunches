$VMLocation = "E:\VMs"
$VMISO = "C:\HydrationCM2012R2SP1\ISO\HydrationCM2012R2SP1.iso"
$VMNetwork = "Internal"

# Create CM01
$VMName = "HYD-CM2012R2SP1-CM01"
$VMMemory = 16384MB
$VMDiskSize = 300GB
New-VM -Name $VMName -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose

# Create DC01
$VMName = "HYD-CM2012R2SP1-DC01"
$VMMemory = 1024MB
$VMDiskSize = 60GB
New-VM -Name $VMName -BootDevice CD -MemoryStartupBytes $VMMemory -SwitchName $VMNetwork -Path $VMLocation -NoVHD -Verbose
New-VHD -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -SizeBytes $VMDiskSize -Verbose
Add-VMHardDiskDrive -VMName $VMName -Path "$VMLocation\$VMName\Virtual Hard Disks\$VMName-Disk1.vhdx" -Verbose
Set-VMDvdDrive -VMName $VMName -Path $VMISO -Verbose