# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "root\SMS\site_$CMSiteCode"

# 1.0 Get Deployment Objects

$BootImageID = (Get-CMBootImage -Name 'Boot Image - Windows 10 (x64)').PackageID
$OSImageID = (Get-CMOperatingSystemImage -Name 'Windows 10 x64 Enterprise Gold').PackageID
$ClientPackageID = (Get-CMPackage -Name 'Configuration Manager Client Package').PackageID


# 1.1 Create Task Sequence

New-CMTaskSequence -InstallOperatingSystemImageOption `
  -TaskSequenceName 'Deploy Windows 10 x64 Enterprise' `
  -BootImagePackageId $BootImageID `
  -OperatingSystemImagePackageId $OSImageID `
  -OperatingSystemImageIndex '1' `
  -ClientPackagePackageId $ClientPackageID `
  -JoinDomain DomainType `
  -DomainName 'mol.sccmlab.net' `
  -DomainAccount 'MOL\CM_JD' `
  -DomainPassword 'P@ssw0rd' `
  -DomainOrganizationUnit 'LDAP://OU=Workstations,OU=MoL,DC=mol,DC=sccmlab,DC=net' `
  -PartitionAndFormatTarget $true `
  -LocalAdminPassword 'P@ssw0rd'
