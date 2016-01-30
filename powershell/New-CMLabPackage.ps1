# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "root\SMS\site_$CMSiteCode"
$PackageName = 'Notepad++ 6.8.9'

# 1.0 Create new Package

New-CMPackage -Name $PackageName -Path '\\cm01\Sources\Software\Notepad++ 6.8.9'

# 1.1 Create new Program

New-CMProgram -PackageName $PackageName
  -StandardProgramName 'Install - Notepad++ 6.8'
  -CommandLine 'npp.6.8.9.Installer.exe /S'
  -RunType Hidden
  -RunMode RunWithAdministrativeRights
  -UserInteraction $false
  -ProgramRunType WhetherOrNotUserIsLoggedOn
  -DriveMode RenameWithUnc
