function Get-ResourcePoolID {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword
    )
        try {
            
            # Create API Endpoint
            $rpUrl = [string]::Format(
                "{0}" +
                "api/vcenter/resource-pool",
                $vCenter
            )
            
            # Make the request
            $response = Invoke-APIRequest -method "Get" `
                                        -url $rpUrl `
                                        -vCenter $vCenter `
                                        -vCenterUserName $vCenterUserName `
                                        -vCenterPassword $vCenterPassword
            
            if ($response) {
                return ($response | Where-Object { $_.name -eq "Resources" } | Select-Object -ExpandProperty resource_pool)
            }
        }
        catch {
            Write-Error "Failed to get Resource Pool ID: $_"
        }
}