# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "root\SMS\site_$CMSiteCode"
$CustomSettingsName = 'Desktop Software Inventory Settings'

# 1.0 Create new Client Settings

New-CMClientSetting -Name $CustomSettingsName -Type Device

# 1.1 Enable Software Inventory

Set-CMClientSetting -Name $CustomSettingsName `
  -SoftwareInventorySettings `
  -EnableSoftwareInventory $true

# 1.2 Configure Software Inventory Settings

$Settings = Get-CimInstance -ComputerName $CMSiteServer -Namespace $CMNameSpace -ClassName SMS_ClientSettings | Where-Object {$_.Name -eq $CustomSettingsName}

$InventorySettings = New-CimInstance -ClientOnly `
  -Namespace $CMNameSpace `
  -ClassName SMS_SoftwareInventoryAgentConfig `
  -Property @{AgentID=[uint32]'2';
            Enabled=[boolean]'True';
            Exclude=[string[]]'True';
            ExcludeWindirAndSubfolders=[string[]]'True';
            InventoriableTypes=[string[]]'*.exe';
            Path=[string[]]'*';
            ReportOptions=[uint32]'7';
            Schedule='0001200000100038';
            Subdirectories=[string[]]'True'}

$settings.AgentConfigurations += $InventorySettings

Get-CimInstance -ComputerName $CMSiteServer -Namespace $CMNameSpace -ClassName SMS_ClientSettings | Where-Object {$_.Name -eq $CustomSettingsName} | Set-CimInstance -Property @{AgentConfigurations=$Settings.AgentConfigurations}
