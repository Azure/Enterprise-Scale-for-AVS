[CmdletBinding()]
param (
    [Parameter()]
    [string]$ParameterFile = ".\Main.parameters.ps1",
    
    [Parameter(Mandatory=$true)]
    [secureString]$hcxConnectorPassword
)

. .\Start-Processing.ps1

# Import parameter values
if (-not (Test-Path $ParameterFile)) {
    Write-Host "Parameter file not found: $ParameterFile"
    exit 1
}

# Source the parameter file to load all variables into current scope
. $ParameterFile

# Ensure hcxConnectorPassword has a value
if ([string]::IsNullOrEmpty($hcxConnectorPassword)) {
    $hcxConnectorPassword = Read-Host -Prompt "Enter HCX Connector password" -AsSecureString
    # Convert SecureString to plain text if needed by Start-Processing
    $hcxConnectorPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($hcxConnectorPassword))
}

# Start Processing with just the password and parameter file path
# No need to pass individual parameters since they'll be sourced inside the function

try {
    $result = Start-Processing -ParameterFile $ParameterFile -hcxConnectorPassword $hcxConnectorPassword

    if ($result) {
        Write-Host "Automated ServiceMesh creation completed successfully."
    } else {
        Write-Host "Automated ServiceMesh creation failed."
    }
}
catch {
    Write-Host "An error occurred: $_"
}

