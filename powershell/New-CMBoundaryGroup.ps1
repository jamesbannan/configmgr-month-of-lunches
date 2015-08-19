# Define Configuration Manager variables

$CMSiteCode = 'PS1'
$BoundaryName = 'mol.sccmlab.net/Lab'
$BoundaryGroupName = 'Lab Boundaries'

# 1.0 Get Existing Boundary

$Boundary = Get-CMBoundary -BoundaryName $BoundaryName

# 1.1 Create Boundary Group

New-CMBoundaryGroup -Name $BoundaryGroupName `
  -Description 'All Boundaries in the ConfigMgr Lab environment' `
  -DefaultSiteCode $CMSiteCode `

# 1.2 Get Newly-created Boundary Group

$NewBoundaryGroup = Get-CMBoundaryGroup -Name $BoundaryGroupName

# 1.3 Add Boundary to Boundary Group

Add-CMBoundaryToGroup -BoundaryName $Boundary.DisplayName -BoundaryGroupName $NewBoundaryGroup.Name
