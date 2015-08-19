# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "root\SMS\site_$CMSiteCode"
$DriverPackageName = 'Dell Latitude E5440 – Windows 10 x64 - A00'
$DriverPackageSource = '\\cm01\sources\Driver Packages\Dell Latitude E5440 - Windows 10 x64 - A00'
$DriverSource = '\\cm01\sources\Drivers\Dell Latitude E5440\Windows 10 x64'
$DriverCategoryName01 = 'Windows 10 x64'
$DriverCategoryName02 = 'Dell Latitude E5440'

# 1.0 Create Driver Package

New-CMDriverPackage -Name $DriverPackageName -Path $DriverPackageSource -Verbose

$DriverPackage = Get-CMDriverPackage -Name $DriverPackageName

Start-CMContentDistribution -DriverPackageName $DriverPackage.Name -DistributionPointName $CMSiteServer -Verbose

# 1.1 Create Administrative Categories

If ((Get-CMCategory -Name $DriverCategoryName01) -eq $null) {
  New-CMCategory -CategoryType DriverCategories -Name $DriverCategoryName01
}

$DriverCategory01 = Get-CMCategory -Name $DriverCategoryName01

If ((Get-CMCategory -Name $DriverCategoryName02) -eq $null) {
  New-CMCategory -CategoryType DriverCategories -Name $DriverCategoryName02
}

$DriverCategory02 = Get-CMCategory -Name $DriverCategoryName02

# 1.2 Build Category array

$DriverCategories = @()
$DriverCategories += $DriverCategory01
$DriverCategories += $DriverCategory02

# 1.3 Get Drivers

Set-Location C:

$Drivers = Get-ChildItem -Path $DriverSource -Include *.inf -Recurse

Set-Location ($CMSiteCode + ':')

# 1.4 Import Drivers

foreach ($driver in $drivers){
  Import-CMDriver -UncFileLocation $Driver.FullName `
    -DriverPackage $DriverPackage `
    -EnableAndAllowInstall $true `
    -AdministrativeCategory $DriverCategories `
    -ImportDuplicateDriverOption AppendCategory `
    -ErrorAction SilentlyContinue `
    -Verbose
    }
