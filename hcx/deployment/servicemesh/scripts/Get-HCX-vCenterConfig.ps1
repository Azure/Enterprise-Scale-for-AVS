. .\Invoke-API.ps1

function Get-HCX-vCenterConfig {
    param (    
        [string]$hcxConnectorMgmtUrl,
        [SecureString]$hcxConnectorPassword
    )
    try{
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "api/admin/global/config/vcenter",
            $hcxConnectorMgmtUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -userName 'admin' `
            -password $hcxConnectorPassword `
            -AuthType "Basic"

        # Process the response
        if ($response) {
            # Iterate through the $response.data.items
            foreach ($item in $response.data.items) {
                if ($item.config) {
                    return $item.config
                }
            }
        } else {
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving HCX vCenter configuration: $_"
    }
}