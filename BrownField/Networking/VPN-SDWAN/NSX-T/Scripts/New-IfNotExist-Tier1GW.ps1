function New-IfNotExist-Tier1GW {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dhcpProfileName,
        [string]$tier1GatewayIp = $null,
        [string]$tier1GatewaySubnet = $null,
        [string]$tier1GatewayASN = $null,
        [string]$tier1GatewayBgpPeerIp = $null,
        [string]$tier1GatewayBgpPeerASN = $null
    )

    $dhcpProfile = $null

    $dhcpProfile = Get-Tier1GW -avsnsxTmanager $avsnsxTmanager `
                           -nsxtUserName $nsxtUserName `
                           -nsxtPassword $nsxtPassword `
                           -tier1GatewayName $tier1GatewayName

    if ($null -eq $dhcpProfile) {
        Write-Host "Creating Tier1 Gateway: '$tier1GatewayName'"

        $dhcpProfile = New-Tier1GW -avsnsxTmanager $avsnsxTmanager `
                    -nsxtUserName $nsxtUserName `
                    -nsxtPassword $nsxtPassword `
                    -tier1GatewayName $tier1GatewayName `
                    -dhcpProfileName $dhcpProfileName `
                    -tier1GatewayIp $tier1GatewayIp `
                    -tier1GatewaySubnet $tier1GatewaySubnet `
                    -tier1GatewayASN $tier1GatewayASN `
                    -tier1GatewayBgpPeerIp $tier1GatewayBgpPeerIp `
                    -tier1GatewayBgpPeerASN $tier1GatewayBgpPeerASN
    }

    return $dhcpProfile
}

function Get-Tier1GW {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName
    )

    $nsxTT1url = "$avsnsxTmanager/policy/api/v1/infra/tier-1s"

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $nsxTT1url `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or $null -eq $response.results) {
            return $null
        }

        return $response.results | ForEach-Object {
            if ($_.display_name -eq $tier1GatewayName) {
                $dhcpProfile = Get-DHCPProfile -avsnsxTmanager $avsnsxTmanager `
                                 -nsxtUserName $nsxtUserName `
                                 -nsxtPassword $nsxtPassword `
                                 -tier1GatewayName $tier1GatewayName `
                                 -dhcpProfileName $_.dhcp_config_paths[0].split("/")[-1]

                $dhcpServerAddress = $dhcpProfile.DHCPServer_Address

                Write-Host "Tier1 Gateway '$tier1GatewayName' with DHCP Server '$dhcpServerAddress' already exists"
                return $dhcpProfile
            }
        }
    }
    catch {
        Write-Error "Failed to get NSX-T T1 Gateways: $_"
        return $null
    }
}

function New-Tier1GW {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dhcpProfileName,
        [string]$tier1GatewayIp = $null,
        [string]$tier1GatewaySubnet = $null,
        [string]$tier1GatewayASN = $null,
        [string]$tier1GatewayBgpPeerIp = $null,
        [string]$tier1GatewayBgpPeerASN = $null
    )

    $nsxTT1url = "$avsnsxTmanager/policy/api/v1/infra?enforce_revision_check=true"
    #$nsxTT1url = "$avsnsxTmanager/policy/api/v1/infra"

    try {
        $tier0GatewayName = Get-Tier0_Name -avsnsxTmanager $avsnsxTmanager `
                                           -nsxtUserName $nsxtUserName `
                                           -nsxtPassword $nsxtPassword `
                                           -tier1GatewayName $tier1GatewayName

        $edgeClusterPath = Get-EdgeCluster_Path -avsnsxTmanager $avsnsxTmanager `
                                                -nsxtUserName $nsxtUserName `
                                                -nsxtPassword $nsxtPassword `
                                                -tier1GatewayName $tier1GatewayName

        $dhcpProfile = Get-DHCPProfile -avsnsxTmanager $avsnsxTmanager `
                                             -nsxtUserName $nsxtUserName `
                                             -nsxtPassword $nsxtPassword `
                                             -tier1GatewayName $tier1GatewayName `
                                             -dhcpProfileName $dhcpProfileName
                                               
        if ($null -eq $dhcpProfile -or 
            $null -eq $dhcpProfile.DHCPProfile_Path -or
            $null -eq $dhcpProfile.DHCPServer_Address) { 
            Write-Host "Failed to get DHCP Profile. Creating a new one..."
            $dhcpProfile = New-DHCPProfile -avsnsxTmanager $avsnsxTmanager `
                                 -nsxtUserName $nsxtUserName `
                                 -nsxtPassword $nsxtPassword `
                                 -tier1GatewayName $tier1GatewayName `
                                 -dhcpProfileName $dhcpProfileName `
                                 -edgeClusterPath $edgeClusterPath

        }                                              

        if ($null -eq $edgeClusterPath -or 
            $null -eq $tier0GatewayName -or 
            $null -eq $dhcpProfile.DHCPProfile_Path -or
            $null -eq $dhcpProfile.DHCPServer_Address) {
            Write-Host "Either Edge Cluster Path, Tier0 Gateway Name or DHCP Profile is null. Exiting..."
            return $false
        }

        $body = @{
            resource_type = "Infra"
            children = @(
                @{
                    resource_type = "ChildTier1"
                    Tier1 = @{
                        resource_type = "Tier1"
                        ha_mode = "ACTIVE_STANDBY"
                        route_advertisement_types = @(
                            "TIER1_STATIC_ROUTES"
                            "TIER1_CONNECTED"
                            "TIER1_DNS_FORWARDER_IP"
                            "TIER1_IPSEC_LOCAL_ENDPOINT"
                        )
                        display_name = $tier1GatewayName
                        tier0_path = "/infra/tier-0s/$tier0GatewayName"
                        failover_mode = "NON_PREEMPTIVE"
                        id = $tier1GatewayName
                        children = @(
                            @{
                                resource_type = "ChildLocaleServices"
                                LocaleServices = @{
                                    resource_type = "LocaleServices"
                                    id = "default"
                                    edge_cluster_path = $edgeClusterPath
                                }
                            }
                        )
                        dhcp_config_paths = @($dhcpProfile.DHCPProfile_Path)
                    }
                }
            )
        }

        $response = Invoke-APIRequest -method "PATCH" `
                                      -url $nsxTT1url `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword `
                                      -body ($body | ConvertTo-Json -Depth 10)

        if ($response.StatusCode -eq 200) {
            return $dhcpProfile
        }
    }
    catch {
        Write-Error "Failed to create NSX-T T1 Gateway: $_"
        return $null
    }
}

function Get-EdgeCluster_Path {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName
    )

    $edgeclusterPathUrl = "$avsnsxTmanager/policy/api/v1/infra/sites/default/enforcement-points/default/edge-clusters"

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $edgeclusterPathUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or $null -eq $response.results -or $response.results.Count -eq 0) {
            return $null
        }

        return $response.results[0].path
    }
    catch {
        Write-Error "Failed to get NSX-T Edge Cluster Path: $_"
        return $null
    }
}

function Get-Tier0_Name {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName
    )

    $t0nameUrl = "$avsnsxTmanager/policy/api/v1/infra/tier-0s"

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $t0nameUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or $null -eq $response.results -or $response.results.Count -eq 0) {
            return $null
        }

        return $response.results[0].display_name
    }
    catch {
        Write-Error "Failed to get NSX-T Tier-0 Name: $_"
        return $null
    }
}
function Get-DHCPProfile {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dhcpProfileName
    )

    $dhcpProfileUrl = "$avsnsxTmanager/policy/api/v1/infra/dhcp-server-configs"

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $dhcpProfileUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or $null -eq $response.results -or $response.results.Count -eq 0) {
            return $null
        }

        foreach ($result in $response.results) {
            if ($result.display_name -eq $dhcpProfileName) {
                return @{
                    DHCPProfile_Path = $result.path
                    DHCPServer_Address = $result.server_address
                }
            }
        }
        return $null
    }
    catch {
        Write-Error "Failed to get DHCP Profile: $_"
        return $null
    }
}
function New-DHCPProfile {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dhcpProfileName,
        [string]$edgeClusterPath
    )

    $dhcpProfileUrl = "$avsnsxTmanager/policy/api/v1/infra/dhcp-server-configs/$dhcpProfileName"

    try {

        $dhcpServerAddress = Get-RandomRFC1918Address

        $body = @{
            resource_type = "DhcpServerConfig"
            display_name = $dhcpProfileName
            id = $dhcpProfileName
            server_address = $dhcpServerAddress
            edge_cluster_path = $edgeClusterPath
        }
        
        $response = Invoke-APIRequest -method "Put" `
                          -url $dhcpProfileUrl `
                          -avsnsxtUrl $avsnsxTmanager `
                          -avsnsxtUserName $nsxtUserName `
                          -avsnsxtPassword $nsxtPassword `
                          -body ($body | ConvertTo-Json -Depth 10)

        if ($null -eq $response -or $null -eq $response.path) {
            return $null
        } else {
            return @{
                DHCPProfile_Path = $response.path
                DHCPServer_Address = $dhcpServerAddress
            }
        }
    }
    catch {
        Write-Error "Failed to get DHCP Profile: $_"
        return $null
    }
}

function Get-RandomRFC1918Address {
    try {

        $range = Get-Random -Minimum 1 -Maximum 4
        switch ($range) {
            1 { 
            $ip = "10.$(Get-Random -Minimum 0 -Maximum 255)." +
                  "$(Get-Random -Minimum 0 -Maximum 255)." +
                  "1/24" 
            }
            2 { 
            $ip = "172.$(Get-Random -Minimum 16 -Maximum 31)." +
                  "$(Get-Random -Minimum 0 -Maximum 255)." +
                  "1/24" 
            }
            3 { 
            $ip = "192.168.$(Get-Random -Minimum 0 -Maximum 255)." +
                  "1/24" 
            }
        }
        Write-Host "Creating DHCP Server IP: $ip"
        return $ip        
    }
    catch {
        Write-Error "Failed to Create DHCP IP address: $_"
        return $null
    }
}