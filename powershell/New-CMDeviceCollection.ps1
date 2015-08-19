# Define Configuration Manager variables

$CollectionName = 'All Windows 10 Clients'
$LimitingCollectionID = (Get-CMDeviceCollection | Where-Object {$_.Name -eq 'All Desktop and Server Clients'}).CollectionID
$CMSchedule = New-CMSchedule -Start '2014/01/01 00:00:00' -RecurInterval Days -RecurCount 1

# 1.0 Create new Device Collection

New-CMDeviceCollection -Name $CollectionName `
  -LimitingCollectionId $LimitingCollectionID `
  -RefreshType Both `
  -RefreshSchedule $CMSchedule

# 1.1 Create new Collection Query Rule

$Collection = Get-CMDeviceCollection -Name $CollectionName

Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollectionName `
  -QueryExpression 'select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.OperatingSystemNameandVersion like "%Workstation 10%"' `
  -RuleName 'Windows 10 Operating System'

# 1.2 Update the collection

Invoke-CMDeviceCollectionUpdate -Name $CollectionName
