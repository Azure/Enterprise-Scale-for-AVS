. .\Invoke-APIRequest.ps1
. .\HeaderHelper.ps1

function New-IfNotExist-HCX-SSOConfig {
    param (
        [string]$vCenter,
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
    )

    # Check if HCX SSO configuration already exists
    $existingConfig = Get-HCX-SSOConfig -vCenterPassword $vCenterPassword -hcxUrl $hcxUrl

    if (-not $existingConfig) {
        New-HCX-SSOConfig -vCenter $vCenter `
            -vCenterPassword $vCenterPassword `
            -hcxUrl $hcxUrl
    }
}

function Get-HCX-SSOConfig {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl
    )

    # Create Auth Header
    $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword

    # Define API URL
    $apiUrl = [string]::Format(
        "{0}" +
        "api/admin/global/config/lookupservice",
        $hcxUrl
    )

    # Make the request to get SSO configuration
    $response = Invoke-WebRequest -method "GET" `
        -Uri $apiUrl `
        -Headers $headers `
        -SkipCertificateCheck

    # Process the response
    if ($response) {
        $content = $response.Content | ConvertFrom-Json
        if ($content.data.items) {
            Write-Host "HCX SSO configuration already exists. Skipping creation."
            return $content.data.items
        }
    } else {
        Write-Error "Failed to retrieve HCX SSO configuration."
        return $null
    }
}

function New-HCX-SSOConfig {
    param (
            [string]$vCenter,
            [SecureString]$vCenterPassword,
            [string]$hcxUrl
        )
    try {

        # Remove trailing slash from vCenter URL if it exists
        if ($vCenter.EndsWith('/')) {
            $vCenter = $vCenter.TrimEnd('/')
        }        
        
        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/lookupservice",
            $hcxUrl
        )    
        
        # Define the body for vCenter configuration
        $body = @{
            data = @{
                items = @(
                    @{
                        config = @{
                            lookupServiceUrl = $vCenter
                            providerType = "PSC"
                        }
                    }
                )
            }
        }

        # Convert the body to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10        
        
        # Make the request
        $response = Invoke-WebRequest -method "POST" `
            -Uri $apiUrl `
            -Body $jsonBody `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            Write-Host "HCX SSO configuration completed successfully."
        }
    }
    catch {
        Write-Error "HCX SSO configuration failed: $_"
    }
}