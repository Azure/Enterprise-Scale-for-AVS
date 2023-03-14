## to build

$rootFolder = (Get-Location).path

# get variables
Write-Output "Reading variables"
#$variables = Get-Content .\variables\variables.json | ConvertFrom-Json
#$variables = Get-Content ..\PowerShell\variables\variables.json | ConvertFrom-Json
& "$rootFolder\variables\set-variables.ps1"
#.\variables\set-variables.ps1
$variables

# Deploy Resource Groups
Write-Output "Deploying Resource Groups now"
& "$rootFolder\1.resource-group\deploy-withjson.ps1"

# Deploy Private Cloud
Write-Output "Deploying Private Cloud now"
& "$rootFolder\2.private-cloud\deploy-withjson.ps1"
#. .\2.private-cloud\deploy-withjson.ps1

& "$rootFolder\2.private-cloud\deploymentcheck.ps1"

# Deploy Networking
Write-Output "Deploying Networking now"
#. .\3.network\deploy-withjson.ps1
#& "$rootFolder\3.network\deploy-withjson.ps1"

# Deploy Jumpbox
write-Output "Deploying Jumpbox now"
#& "$rootFolder\4.jumpbox\deploy-withjson.ps1"
#. .\4.jumpbox\deploy-withjson.ps1