function Get-DatastoreID {
    param (
        [string]$vCenter,
        [string]$vCenterUserName,
        [SecureString]$vCenterPassword,
        [string]$datastoreName
    )
        try {
            # Create API Endpoint to get the Cluster ID
            $datastoreUrl = [string]::Format(
                "{0}" +
                "api/vcenter/datastore",
                $vCenter
            )            
            
            # Make the request with explicit parameter binding
            $response = Invoke-APIRequest -method "Get" `
                -url $datastoreUrl `
                -vCenter $vCenter `
                -vCenterUserName $vCenterUserName `
                -vCenterPassword $vCenterPassword

            # Process the response
            if ($response) {
                return $response.Where({ $_.name -eq $datastoreName }).datastore
            } else {
                Write-Error "Failed to get Datastore ID. Check the parameter values and/or vCenter Password."
                return $null
            }
        }
        catch {
            Write-Error "Get DatastoreID failed: $_"
        }
}