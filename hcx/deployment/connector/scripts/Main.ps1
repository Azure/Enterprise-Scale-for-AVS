[CmdletBinding()]
param (
    [Parameter()]
    [string]$ParameterFile = ".\Main.parameters.ps1",
    
    [Parameter(Mandatory=$true)]
    [secureString]$vCenterPassword
)

. .\Invoke-APIRequest.ps1
. .\Start-Processing.ps1

# Import parameter values
if (-not (Test-Path $ParameterFile)) {
    Write-Host "Parameter file not found: $ParameterFile" -ForegroundColor Red
    exit 1
}

# Source the parameter file to load all variables into current scope
. $ParameterFile

# Start Processing with just the password and parameter file path
# No need to pass individual parameters since they'll be sourced inside the function
Start-Processing -ParameterFile $ParameterFile -vCenterPassword $vCenterPassword