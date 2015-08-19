# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$CMSiteServer = 'CM01.mol.sccmlab.net'
$CMNameSpace = "rootSMSsite_$CMSiteCode"

# 1.0 Create array of names for Folders

$Folders = @()
$Folders += 'Application Deployment'
$Folders += 'Operating System Deployment'
$Folders += 'Software Update Deployment'

# 1.1 Create a folder for each name in the array

foreach ($Folder in $Folders){
  $Arguments = @{Name = $Folder; ObjectType = 5000; ParentContainerNodeId = 0}
  Set-WmiInstance -ComputerName $CMSiteServer -Namespace $CMNameSpace -Class SMS_ObjectContainerNode -Arguments $Arguments
}

# Tip - you may need to close and re-open the Configuration Manager console to see the changes
