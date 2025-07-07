function Get-Resource-Containers {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/service/inventory/resourcecontainer/list",
            $hcxConnectorServiceUrl
        )

        # Define Body
        $body = @{
            filter = @{
                cloud = @{
                    local  = $true
                    remote = $true
                }
            }
        }

        $jsonBody = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -body $jsonBody `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response -and $response.items.Count -gt 0) {
            return $response.items
        } else {
            Write-Error "No HCX inventory found or failed to retrieve."
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving HCX inventory: $_"
    }
}

function Get-Cluster {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/vc/query?entityType=cluster",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response) {
            return $response
        } else {
            Write-Error "No vCenter found or failed to retrieve."
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving vCenter: $_"
    }
}

function Get-Datacenter {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/vc/query?entityType=datacenter",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response) {
            return $response
        } else {
            Write-Error "No vCenter found or failed to retrieve."
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving vCenter: $_"
    }
}

function Get-DVS {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/vc/query?entityType=dvs",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response) {
            return $response
        } else {
            Write-Error "No DVS found or failed to retrieve."
            return $null
        }
    }
    catch {
        Write-Error "Error retrieving DVS: $_"
    }
}

function Get-Consolidated-Data {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )

    try {
        # Get Cluster Data
        $clusterData = Get-Cluster -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if (-not $clusterData) {
            Write-Error "Failed to retrieve clusters."
            return $null
        }

        # Get Datacenter Data
        $datacenterData = Get-Datacenter -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if (-not $datacenterData) {
            Write-Error "Failed to retrieve datacenters."
            return $null
        }

        # Get DVS Data
        $dvsData = Get-DVS -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if (-not $dvsData) {
            Write-Error "Failed to retrieve DVS."
            return $null
        }

        # Search for the first Datastore that is not empty
        $datastore = $clusterData.datastore | Where-Object { $_.type -eq "Datastore" } | Select-Object -First 1
        if ($datastore) {
            $datastoreId = $datastore.value
        } else {
            Write-Host "No valid datastore found in the cluster."
            $datastoreId = $null
        }

        return @{
            datacenter_id = $datacenterData.entity_id
            vcenter_instanceId = $clusterData.vcenter_instanceId
            vcenter_entity_id = $clusterData.entity_id
            datastore_id = $datastoreId
            dvs_id = $dvsData.entity_id
        }
    }
    catch {
        Write-Error "Error retrieving consolidated data: $_"
    }
}