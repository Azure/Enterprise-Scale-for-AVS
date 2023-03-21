## to build

# get variables
Write-Output "Reading variables"
#$variables = Get-Content .\variables\variables.json | ConvertFrom-Json
. .\variables\set-variables.ps1

# Deploy Resource Groups
Write-Output "Deploying Resource Groups now"
. .\1.resource-group\deploy-withjson.ps1

# Deploy Private Cloud
Write-Output "Deploying Priavte Cloud now"
. .\2.private-cloud\deploy-withjson.ps1

# Deploy Networking
Write-Output "Deploying Networking now"
. .\3.network\deploy-withjson.ps1

# Deploy Jumpbox
write-Output "Deploying Jumpbox now"
. .\4.jumpbox\deploy-withjson.ps1