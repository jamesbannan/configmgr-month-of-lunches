# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "root\SMS\site_$CMSiteCode"
$ApplicationName = 'Paint.NET 4.0.5'

# 1.0 Create new Application

New-CMApplication -Name $ApplicationName -LocalizedApplicationName $ApplicationName

$Application = Get-CMApplication -Name $ApplicationName

# 1.1 Create x64 Deployment Type

Add-CMDeploymentType -ApplicationName $Application.LocalizedDisplayName `
  -AutoIdentifyFromInstallationFile `
  -ForceForUnknownPublisher $true `
  -InstallationFileLocation '\\CM01\Sources\Software\Paint.NET\4.0.5\x64\PaintDotNet.x64.msi' `
  -MsiInstaller `
  -DeploymentTypeName 'Paint.NET 4.0.5 (x64) - Windows Installer (*.msi file)'

# 1.2 Create x86 Deployment Type

Add-CMDeploymentType -ApplicationName $Application.LocalizedDisplayName `
  -AutoIdentifyFromInstallationFile `
  -ForceForUnknownPublisher $true `
  -InstallationFileLocation '\\CM01\Sources\Software\Paint.NET\4.0.5\x86\PaintDotNet.x86.msi' `
  -MsiInstaller `
  -DeploymentTypeName 'Paint.NET 4.0.5 (x86) - Windows Installer (*.msi file)'
