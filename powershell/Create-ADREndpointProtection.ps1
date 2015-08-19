# Define Configuration Manager variables
$coll = Get-CMDeviceCollection -Name 'All Desktop and Server Clients'
$package = Get-CMSoftwareUpdateDeploymentPackage -Name 'Endpoint Protection Definitions'

# 1.0 Create CM Schedule for ADR
$Schedule = New-CMSchedule -RecurInterval Days -RecurCount 1

# 1.1 Create ADR for Endpoint Protection Definition Updates
New-CMSoftwareUpdateAutoDeploymentRule `
    -Name 'ADR - Endpoint Protection Definitions' `
    -CollectionName $coll.Name `
    -AddToExistingSoftwareUpdateGroup $true `
    -EnabledAfterCreate $True `
    -VerboseLevel OnlyErrorMessages `
    -DeployWithoutLicense $True `
    -SendWakeUpPacket $False `
    -DateReleasedOrRevised Last1day `
    -Product 'Forefront Endpoint Protection 2010' `
    -Superseded $False `
    -UpdateClassification 'Definition Updates' `
    -RunType RunTheRuleOnSchedule `
    -Schedule $Schedule `
    -UseUtc $False `
    -AvailableImmediately $True `
    -DeadlineImmediately $True `
    -UserNotification HideAll `
    -AllowSoftwareInstallationOutsideMaintenanceWindow $True `
    -AllowRestart $False `
    -SuppressRestartServer $True `
    -SuppressRestartWorkstation $True `
    -WriteFilterHandling $False `
    -SuccessPercent 75 `
    -AlertTimeUnit Days `
    -AlertTime 2 `
    -GenerateSuccessAlert $False `
    -DisableOperationManager $False `
    -GenerateOperationManagerAlert $False `
    -NoInstallOnRemote $False `
    -NoInstallOnUnprotected $False `
    -UseBranchCache $False `
    -DownloadFromMicrosoftUpdate $True `
    -AllowUseMeteredNetwork $True `
    -DeploymentPackageName $package.Name `
    -DownloadFromInternet $True `
    -LanguageSelection 'English' `
    -Verbose
