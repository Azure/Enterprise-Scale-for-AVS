. .\Invoke-APIRequest.ps1
. .\HeaderHelper.ps1

function New-IfNotExist-HCX-RoleMappings {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [string]$hcxAdminGroup
    )
    
    # Check if HCX Role Mappings already exist
    $existingMappings = Get-HCX-RoleMappings -vCenterPassword $vCenterPassword `
                            -hcxUrl $hcxUrl `
                            -hcxAdminGroup $hcxAdminGroup

    if (-not $existingMappings) {
        New-HCX-RoleMappings -vCenter $vCenter `
            -vCenterUserName $vCenterUserName `
            -vCenterPassword $vCenterPassword `
            -hcxUrl $hcxUrl `
            -hcxAdminGroup $hcxAdminGroup
    }
}
function Get-HCX-RoleMappings {
    param (
        [SecureString]$vCenterPassword,
        [string]$hcxUrl,
        [string]$hcxAdminGroup
    )

    try {
        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/roleMappings",
            $hcxUrl
        )        
        
        # Make the request
        $response = Invoke-WebRequest -method "GET" `
            -Uri $apiUrl `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            $content = $response.Content | ConvertFrom-Json
            foreach ($mapping in $content) {
                if ($mapping.userGroups -contains $hcxAdminGroup) {
                    Write-Host "HCX Role Mappings already exists. Skipping creation."
                    return $mapping
                }
            } 
        }
    }
    catch {
        Write-Error "HCX Role Mappings retrieval failed: $_"
    }
}
function New-HCX-RoleMappings {
    param (
            
            [string]$vCenter,
            [string]$vCenterUserName,
            [SecureString]$vCenterPassword,
            [string]$hcxUrl,
            [string]$hcxAdminGroup
        )    try {

        # Create Auth Header
        $headers = Get-Standard-Headers -vCenterPassword $vCenterPassword
        
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/roleMappings",
            $hcxUrl
        )        
        
        # Define the body - HCX API expects an array format
        $body = @(
            @{
                role = "System Administrator"
                userGroups = @($hcxAdminGroup)
            }
        )

        # Convert the body to JSON - For single-item arrays, we need to ensure array format
        $jsonBody = ConvertTo-Json -InputObject @($body) -Depth 10
        
        # Ensure we have array format even with single item
        if (-not $jsonBody.StartsWith('[')) {
            $jsonBody = "[$jsonBody]"
        }

        # Make the request
        $response = Invoke-WebRequest -method "PUT" `
            -Uri $apiUrl `
            -Body $jsonBody `
            -Headers $headers `
            -SkipCertificateCheck

        # Process the response
        if ($response) {
            Write-Host "HCX Role Mappings configured successfully."
        }
    }
    catch {
        Write-Error "HCX Role Mappings configuration failed: $_"
    }
}