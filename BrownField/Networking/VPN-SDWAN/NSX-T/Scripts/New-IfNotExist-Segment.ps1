function New-IfNotExist-Segment {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$segmentName,
        [string]$dnsServerAddress,
        [string]$dhcpProfilePath
    )

    $segmentAddress = Get-Segment -avsnsxTmanager $avsnsxTmanager `
                                  -nsxtUserName $nsxtUserName `
                                  -nsxtPassword $nsxtPassword `
                                  -segmentName $segmentName

    if ($segmentAddress) {
        Write-Host "Segment '$segmentName' already exists."
    } else {
        try {
            Write-Host "Segment '$segmentName' not found. Creating..."
            $segmentAddress = New-Segment -avsnsxTmanager $avsnsxTmanager `
                        -nsxtUserName $nsxtUserName `
                        -nsxtPassword $nsxtPassword `
                        -tier1GatewayName $tier1GatewayName `
                        -segmentName $segmentName `
                        -dnsServerAddress $dnsServerAddress `
                        -dhcpProfilePath $dhcpProfilePath
        } catch {
            Write-Error "Failed to create segment '$segmentName': $_"
        }
    }
    return $segmentAddress
}

function Get-Segment {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$segmentName
    )

    $segmenturl = "$avsnsxTmanager/policy/api/v1/search/aggregate?page_size=50&cursor=0&sort_by=display_name" +
                        "&sort_ascending=true"

    $body = @{
        primary = @{
            resource_type = "Segment"
            filters = @(
                @{
                    field_names = "!_exists_"
                    value = "advanced_config.origin_id"
                    case_sensitive = $true
                }
            )
        }
        related = @(
            @{
                resource_type = "Tier0 OR Tier1"
                join_condition = "path:connectivity_path"
                alias = "connectivity"
            },
            @{
                resource_type = "SegmentDiscoveryProfileBindingMap"
                join_condition = "parent_path:path"
                alias = "SegmentDiscoveryProfileBindingMap"
            },
            @{
                resource_type = "SegmentSecurityProfileBindingMap"
                join_condition = "parent_path:path"
                alias = "SegmentSecurityProfileBindingMap"
            },
            @{
                resource_type = "SegmentQoSProfileBindingMap"
                join_condition = "parent_path:path"
                alias = "SegmentQoSProfileBindingMap"
            },
            @{
                resource_type = "IPDiscoveryProfile"
                join_condition = "path:$1.ip_discovery_profile_path"
                alias = "IPDiscoveryProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "MacDiscoveryProfile"
                join_condition = "path:$1.mac_discovery_profile_path"
                alias = "MacDiscoveryProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "SpoofGuardProfile"
                join_condition = "path:$2.spoofguard_profile_path"
                alias = "SpoofGuardProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "SegmentSecurityProfile"
                join_condition = "path:$2.segment_security_profile_path"
                alias = "SegmentSecurityProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "QoSProfile"
                join_condition = "path:$3.qos_profile_path"
                alias = "QoSProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "DhcpServerConfig OR DhcpRelayConfig"
                join_condition = "path:dhcp_config_path"
                alias = "DhcpServerConfig"
                included_fields = "path,parent_path,display_name,id,edge_cluster_path,resource_type,server_addresses"
            },
            @{
                resource_type = "L2VPNSession"
                join_condition = "path:l2_extension.l2vpn_paths"
                alias = "l2vpn_session"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "Ipv6NdraProfile"
                join_condition = "path:advanced_config.ndra_profile_path"
                alias = "Ipv6NdraProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "SegmentPort"
                join_condition = "parent_path:path"
                alias = "segment_ports"
                size = 0
            },
            @{
                resource_type = "PolicyTransportZone"
                join_condition = "path:transport_zone_path"
                alias = "transport_zone"
                included_fields = "path,parent_path,display_name,id,tz_type,uplink_teaming_policy_names,nsx_id,unique_id,authorized_vlans"
            },
            @{
                resource_type = "EnforcementPoint"
                join_condition = "path:$13.parent_path"
                alias = "EnforcementPoint"
                size = 0
            },
            @{
                resource_type = "Site"
                join_condition = "path:$14.parent_path"
                alias = "Site"
                included_fields = "path,parent_path,display_name,id,unique_id"
            },
            @{
                resource_type = "IpAddressPool"
                join_condition = "path:advanced_config.address_pool_paths"
                alias = "ip_address_pool"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "MetadataProxyConfig"
                join_condition = "path:metadata_proxy_paths"
                alias = "MetadataProxyConfig"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "EvpnTenantConfig"
                join_condition = "path:evpn_tenant_config_path"
                alias = "evpn_tenant"
                included_fields = "path,parent_path,display_name,id,mappings"
            },
            @{
                resource_type = "GenericPolicyRealizedResource"
                join_condition = "intent_paths:path"
                alias = "GenericPolicyRealizedResource"
            },
            @{
                resource_type = "Tier1Interface OR Tier0Interface"
                join_condition = "segment_path:path"
                alias = "interfaces"
                size = 0
            },
            @{
                resource_type = "Ipv6NdraProfile"
                join_condition = "path:$0.ipv6_profile_paths"
                alias = "gatewayNdraProfile"
                included_fields = "path,parent_path,display_name,id"
            },
            @{
                resource_type = "Alarm"
                join_condition = "alarm_source:path"
                alias = "alarms_Segment"
                included_fields = "alarm_source,severity,status"
            }
        )
    }
    
    $body = $body | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-APIRequest -method "POST" `
                                      -url $segmenturl `
                                      -body $body `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword
        $segment = $response.results |
        Where-Object { 
        $_.primary -and 
        $_.primary.display_name -and 
        $_.primary.display_name -eq $segmentName
        } |
        Select-Object -ExpandProperty primary |
        Select-Object -ExpandProperty subnets |
        Select-Object -ExpandProperty network

        if ($null -eq $segment) {
            return $false
        }else {
            return $segment
        }
    }
    catch {
        Write-Error "Failed to get NSX-T Segment: $_"
        return $false
    }
}

function New-Segment {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$segmentName,
        [string]$dnsServerAddress,
        [string]$dhcpProfilePath
    )

    $transportZonePath = Get-TransportZone_Path -avsnsxTmanager $avsnsxTmanager `
                                                -nsxtUserName $nsxtUserName `
                                                -nsxtPassword $nsxtPassword
                                                
    $segmentConfig = New-SegmentConfig -dnsAddress $dnsServerAddress

    if ($null -eq $transportZonePath -or $null -eq $segmentConfig) {
        Write-Error "Failed to create NSX-T Segment: Invalid transport zone path or DHCP configuration."
        return
    }

    $newsegmenturl = "$avsnsxTmanager/policy/api/v1/infra?enforce_revision_check=true"

    $segmentDetails = @{
        resource_type = "Segment"
        display_name = $segmentName
        subnets = @(
            @{
                gateway_address = $segmentConfig.Gateway_Address
                dhcp_ranges = @($segmentConfig.DHCP_Ranges)
                dhcp_config = @{
                    resource_type = "SegmentDhcpV4Config"
                    lease_time = 86400
                    dns_servers = @($dnsServerAddress, "1.1.1.1")
                }
            }
        )
        replication_mode = "MTEP"
        transport_zone_path = $transportZonePath
        admin_state = "UP"
        advanced_config = @{
            address_pool_paths = @()
            multicast = $true
            urpf_mode = "STRICT"
            connectivity = "ON"
        }
        connectivity_path = "/infra/tier-1s/$tier1GatewayName"
        id = $segmentName
    }

    $body = @{
        resource_type = "Infra"
        children = @(
            @{
                resource_type = "ChildSegment"
                Segment = $segmentDetails
            }
        )
    }
    
    $jsonBody = $body | ConvertTo-Json -Depth 10
    #write-host $jsonBody

    try {
        $response = Invoke-APIRequest -method "PATCH" `
                                      -url $newsegmenturl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword `
                                      -body $jsonBody

        if ($null -eq $response) {
            Write-Error "Failed to create NSX-T Segment."
        }elseif ($null -ne $response) {
            Write-Host "NSX-T Segment '$segmentName' created successfully."
            return $segmentConfig.Gateway_Address
        }
    }
    catch {
        Write-Error "Failed to create NSX-T Segment: $_"
    }
}
function New-SegmentConfig {
    param (
        [string]$dnsAddress
    )

    try {
        # Extract the base network address and subnet mask
        $originalNetwork = $dnsAddress
        $prefixLength = 24

        # Generate a new network address that does not overlap with the original network
        $newNetworkBytes = [System.Net.IPAddress]::Parse($originalNetwork).GetAddressBytes()
        $newNetworkBytes[2] = ($newNetworkBytes[2] + 1) % 256  # Change the third octet to ensure a different network
        $newNetwork = [System.Net.IPAddress]::new($newNetworkBytes).ToString()

        # Calculate the gateway address (first address in the new subnet)
        $gatewayAddress = "$($newNetwork.Split('.')[0..2] -join '.').1/$prefixLength"

        # Calculate the DHCP range for the new network
        $dhcpServerIP = [System.Net.IPAddress]::Parse($newNetwork)
        $dhcpServerBytes = $dhcpServerIP.GetAddressBytes()

        # DHCP range (excluding the gateway address)
        $dhcpServerBytes[3] = 2
        $dhcpRangeStart = [System.Net.IPAddress]::new($dhcpServerBytes)

        $dhcpServerBytes[3] = 254
        $dhcpRangeEnd = [System.Net.IPAddress]::new($dhcpServerBytes)

        $dhcpRange = "$dhcpRangeStart-$dhcpRangeEnd"

        return @{
            Gateway_Address = $gatewayAddress
            DHCP_Ranges = @($dhcpRange)
        }
    }
    catch {
        Write-Error "Failed to calculate DHCP configuration: $_"
        return $null
    }
}

function Get-TransportZone_Path {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword
    )

    $transportZonePathUrl = "$avsnsxTmanager/policy/api/v1/infra/sites/default/" +
                            "enforcement-points/default/transport-zones"

    try {
        $response = Invoke-APIRequest -method "Get" `
                                      -url $transportZonePathUrl `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response -or $null -eq $response.results -or $response.results.Count -eq 0) {
            return $null
        }

        foreach ($transportZone in $response.results) {
            if ($transportZone.description -eq "Overlay Transport Zone") {
                return $transportZone.path
            }
        }        

    }
    catch {
        Write-Error "Failed to get NSX-T Transport Zone Path: $_"
        return $null
    }
}