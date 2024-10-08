function New-IfNotExist-LocalEndpoint {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$localEndpointName,
        [string]$localEndpointIp
    )

    $lep_path = Get-LocalEndpoint -avsnsxTmanager $avsnsxTmanager `
                                  -nsxtUserName $nsxtUserName `
                                  -nsxtPassword $nsxtPassword `
                                  -tier1GatewayName $tier1GatewayName `
                                  -vpnServiceName $vpnServiceName `
                                  -localEndpointName $localEndpointName `
                                  -localEndpointIp $localEndpointIp

    if ($lep_path) {
        Write-Host "Local Endpoint with name '$localEndpointName' or with IP '$localEndpointIp' already exists."
        return $lep_path
    } else {
        try {
            Write-Host "Local Endpoint '$localEndpointName' not found. Creating..."
            New-LocalEndpoint -avsnsxTmanager $avsnsxTmanager `
                              -nsxtUserName $nsxtUserName `
                              -nsxtPassword $nsxtPassword `
                              -tier1GatewayName $tier1GatewayName `
                              -vpnServiceName $vpnServiceName `
                              -localEndpointName $localEndpointName `
                              -localEndpointIp $localEndpointIp
            write-host "Local Endpoint '$localEndpointName' created successfully."
        } catch {
            Write-Error "Failed to create Local Endpoint '$localEndpointName': $_"
        }
    }
}

function Get-LocalEndpoint {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$localEndpointName,
        [string]$localEndpointIp
    )

    $localEndpointUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}" +
        "/ipsec-vpn-services/{1}/local-endpoints",
        $tier1GatewayName,
        $vpnServiceName
    )

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $localEndpointUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or 
                $null -eq $response.results -or
                $response.result_count -lt 1) {
            return $false
        }

        foreach ($ipSecVpnLep in $response.results) {
            if (($ipSecVpnLep.display_name -eq $localEndpointName -and
                $ipSecVpnLep.parent_path.split("/")[-1] -eq $vpnServiceName) -or
                $ipSecVpnLep.local_address -eq $localEndpointIp) {
                return $ipSecVpnLep.path
            }
        }

    } catch {
        Write-Error "Failed to get Local Endpoint: $_"
        return $false
    }
}

function New-LocalEndpoint {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$vpnServiceName,
        [string]$localEndpointName,
        [string]$localEndpointIp
    )

    $localEndpointUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}/ipsec-vpn-services/{1}/local-endpoints/{2}",
        $tier1GatewayName,
        $vpnServiceName,
        $localEndpointName
    )

    $localEndpointBody = @{
        display_name  = $localEndpointName
        local_address = $localEndpointIp
        local_id      = $localEndpointIp
        id            = $localEndpointName
    }

    $localEndpointBody = $localEndpointBody | ConvertTo-Json -Depth 10
        
    try {
        $response = Invoke-APIRequest -method "Put" `
                                      -url $localEndpointUrl `
                                      -body $localEndpointBody `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response) {
            Write-Error "Failed to create Local Endpoint '$localEndpointName'."
        } else {
            return $response.path
        }
    } catch {
        Write-Error "Failed to create Local Endpoint '$localEndpointName': $_"
        return
    }
}