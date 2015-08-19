# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "rootSMSsite_$CMSiteCode"


# 1.0 - Configure Forest Discovery

Set-CMDiscoveryMethod -ActiveDirectoryForestDiscovery `
  -SiteCode $CMSiteCode `
  -EnableActiveDirectorySiteBoundaryCreation $true `
  -EnableSubnetBoundaryCreation $false `
  -Enabled $true

# 2.0 - Configure System Discovery

# 2.1 - Define a polling schedule

$CMSystemDiscoverySchedule = New-CMSchedule -Start '2012/10/20 00:00:00' -RecurInterval Days -RecurCount 1

# 2.2 - Create the base discovery method using the schedule

Set-CMDiscoveryMethod -ActiveDirectorySystemDiscovery `
  -SiteCode $CMSiteCode `
  -EnableDeltaDiscovery $true `
  -DeltaDiscoveryIntervalMinutes 5 `
  -EnableFilteringExpiredLogon $true `
  -TimeSinceLastLogonDays 90 `
  -EnableFilteringExpiredPassword $true `
  -TimeSinceLastPasswordUpdateDays 90 `
  -PollingSchedule $CMSystemDiscoverySchedule `
  -Enabled $true

# 2.3 - Add Active Directory containers

$ADSysDiscovery = Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_SYSTEM_DISCOVERY_AGENT"'

$ADContainerProp = $ADSysDiscovery.PropLists | Where-Object {$_.PropertyListName -eq 'AD Containers'}

if ($ADContainerProp.Values -eq $null){
  $ADContainerProp.Values = 'LDAP://OU=Servers,OU=SCCMR2Lab,DC=mol,DC=sccmlab,DC=net',0,1
  }
  else {
  $ADContainerProp.Values += 'LDAP://OU=Servers,OU=SCCMR2Lab,DC=mol,DC=sccmlab,DC=net'
  $ADContainerProp.Values += '0'
  $ADContainerProp.Values += '1'
  }

Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_SYSTEM_DISCOVERY_AGENT"' | Set-CimInstance -Property @{PropLists=$ADSysDiscovery.PropLists}

# 3.0 - Configure Group Discovery

# 3.1 - Define a polling schedule

$CMGroupDiscoverySchedule = New-CMSchedule -Start '2012/10/20 00:00:00' -RecurInterval Days -RecurCount 7

# 3.2 - Create the base discovery method using the schedule

Set-CMDiscoveryMethod -ActiveDirectoryGroupDiscovery `
  -SiteCode $CMSiteCode `
  -EnableDeltaDiscovery $true `
  -DeltaDiscoveryIntervalMinutes 5 `
  -EnableFilteringExpiredLogon $true `
  -TimeSinceLastLogonDays 90 `
  -EnableFilteringExpiredPassword $true `
  -TimeSinceLastPasswordUpdateDays 90 `
  -PollingSchedule $CMGroupDiscoverySchedule `
  -Enabled $true

# 3.3 - Add Active Directory containers

$ADGroupDiscovery = Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT"'

$ADGroupContainers = $ADGroupDiscovery.PropLists | Where-Object {$_.PropertyListName -eq 'AD Containers'}

if ($ADGroupContainers.Values -eq $null){
  $ADGroupContainers.Values = 'SCCM Lab Groups',0,0,1
  }
  else {
  $ADGroupContainers.Values += 'SCCM Lab Groups'
  $ADGroupContainers.Values += '0'
  $ADGroupContainers.Values += '0'
  $ADGroupContainers.Values += '1'
  }

$NewGroupProp = New-CimInstance -ClientOnly -Namespace $CMNameSpace -ClassName SMS_EmbeddedPropertyList -Property @{PropertyListName='Search Bases:SCCM Lab Groups';Values=[string[]]'LDAP://OU=Groups,OU=SCCMR2Lab,DC=mol,DC=sccmlab,DC=net'}
$ADGroupDiscovery.PropLists += $NewGroupProp

Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_SECURITY_GROUP_DISCOVERY_AGENT"' | Set-CimInstance -Property @{PropLists=$ADGroupDiscovery.PropLists}

# 4.0 - Configure User Discovery

# 4.1 - Define a polling schedule

$CMUserDiscoverySchedule = New-CMSchedule -Start '2012/10/20 00:00:00' -RecurInterval Days -RecurCount 1

# 4.2 - Create the base discovery method using the schedule

Set-CMDiscoveryMethod -ActiveDirectoryUserDiscovery `
  -SiteCode $CMSiteCode `
  -EnableDeltaDiscovery $true `
  -DeltaDiscoveryIntervalMinutes 5 `
  -PollingSchedule $CMUserDiscoverySchedule `
  -enabled $true

# 4.3 - Add Active Directory containers

$ADUserDiscovery = Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_USER_DISCOVERY_AGENT"'
$ADUserContainers = $ADUserDiscovery.PropLists | Where-Object {$_.PropertyListName -eq 'AD Containers'}

if ($ADUserContainers.Values -eq $null){
  $ADUserContainers.Values = 'LDAP://OU=Users,OU=SCCMR2Lab,DC=mol,DC=sccmlab,DC=net',0,1
  }
  else {
  $ADUserContainers.Values += 'LDAP://OU=Users,OU=SCCMR2Lab,DC=mol,DC=sccmlab,DC=net'
  $ADUserContainers.Values += '0'
  $ADUserContainers.Values += '1'
  }

Get-CimInstance -ComputerName $CMSiteServer `
    -Namespace $CMNameSpace `
    -ClassName SMS_SCI_Component `
    -Filter 'ComponentName ="SMS_AD_USER_DISCOVERY_AGENT"' | Set-CimInstance -Property @{PropLists=$ADUserDiscovery.PropLists}

# 5.0 - Restart SMS_SITE_COMPONENT_MANAGER Service to apply changes

Get-Service -ComputerName $CMSiteServer -Name SMS_SITE_COMPONENT_MANAGER | Restart-Service
