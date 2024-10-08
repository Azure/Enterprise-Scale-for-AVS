function New-IfNotExist-DNS {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [Securestring]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dnsServiceName,
        [string]$dhcpServerAddress,
        [string]$defaultforwarderzonepath = ""
    )

    $dnsInfo = Get-DNSInfo -avsnsxTmanager $avsnsxTmanager `
                   -nsxtUserName $nsxtUserName `
                   -nsxtPassword $nsxtPassword `
                   -tier1GatewayName $tier1GatewayName `
                   -dnsServiceName $dnsServiceName

    if ($null -eq $dnsInfo.DNSAddress) {
        $dnsInfo = New-DNS -avsnsxTmanager $avsnsxTmanager `
                       -nsxtUserName $nsxtUserName `
                       -nsxtPassword $nsxtPassword `
                       -tier1GatewayName $tier1GatewayName `
                       -dnsServiceName $dnsServiceName `
                       -dhcpServerAddress $dhcpServerAddress `
                       -defaultForwarderZonePath $dnsInfo.DefaultForwarderZonePath
    }

    return $dnsInfo
}

function Get-DNSInfo {
    param(
        [string]$dnsServiceName,
        [string]$tier1GatewayName
    )

    $dnsResults = Get-DNSs -avsnsxTmanager $avsnsxTmanager `
                    -nsxtUserName $nsxtUserName `
                    -nsxtPassword $nsxtPassword `
                    -tier1GatewayName $tier1GatewayName

    $dnsAddress = $dnsResults |
            Where-Object { 
            $_.primary -and 
            $_.primary.display_name -and 
            $_.primary.display_name -eq $dnsServiceName -or
            $_.primary.parent_path.Split("/")[-1] -eq $tier1GatewayName
            } |
            Select-Object -ExpandProperty primary |
            Select-Object -ExpandProperty listener_ip

    $defaultForwarderZonePath = $dnsResults |
            Where-Object {
                $_.primary -and
                $_.primary.default_forwarder_zone_path
            } |
            Select-Object -ExpandProperty primary |
            Select-Object -ExpandProperty default_forwarder_zone_path |
            Select-Object -First 1

    if ($null -ne $dns) {
        Write-Host "DNS Service with name '$dnsServiceName' or for T1 '$tier1GatewayName' already exists."
    }

    return @{
        DNSAddress = $dnsAddress
        DefaultForwarderZonePath = $defaultForwarderZonePath
    }
}
function Get-DNSs {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName
    )

    $getDNSuri = "$avsnsxTmanager/policy/api/v1/search/" +
        "aggregate?page_size=50&cursor=0&sort_by=display_name&sort_ascending=true"

    try {

        $body = @{
            primary = @{
                resource_type = "PolicyDnsForwarder"
            }
            related = @(
                @{
                    resource_type = "Tier0,Tier1"
                    join_condition = "path:parent_path"
                    alias = "gateway"
                },
                @{
                    resource_type = "SPAN"
                    join_condition = "path:$0.path"
                    alias = "gatewaySpan"
                },
                @{
                    resource_type = "PolicyDnsForwarderZone"
                    join_condition = "path:default_forwarder_zone_path"
                    alias = "defaultZone"
                },
                @{
                    resource_type = "PolicyDnsForwarderZone"
                    join_condition = "path:conditional_forwarder_zone_paths"
                    alias = "conditionalZones"
                }
            )
        }

        $jsonBody = $body | ConvertTo-Json -Depth 10

        $response = Invoke-APIRequest -method "POST" `
                                      -url $getDNSuri `
                                      -body $jsonBody `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response) {
            return $null
        }else {
            return $response.results
        }
    }

    catch {
        Write-Error "Failed to get DNSs: $_"
    }
}


function New-DNS {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$dnsServiceName,
        [string]$dhcpServerAddress,
        [string]$defaultForwarderZonePath
    )

    $dnsServerAddress = New-DNS-Address -dhcpServerAddress $dhcpServerAddress

    if ($null -eq $dnsServerAddress) {
        Write-Error "Failed to create DNS Service."
        return
    }

    $newDNSServiceUrl = "$avsnsxTmanager/policy/api/v1/infra?enforce_revision_check=true"

    $body = @{
        resource_type = "Infra"
        children = @(
            @{
                resource_type = "ChildResourceReference"
                id = $tier1GatewayName
                target_type = "Tier1"
                children = @(
                    @{
                        PolicyDnsForwarder = @{
                            resource_type = "PolicyDnsForwarder"
                            log_level = "INFO"
                            enabled = $true
                            display_name = $dnsServiceName
                            listener_ip = $dnsServerAddress
                            cache_size = 1024
                            default_forwarder_zone_path = $defaultForwarderZonePath
                            id = $dnsServiceName
                        }
                        resource_type = "ChildPolicyDnsForwarder"
                    }
                )
            }
        )
    }

    $body = $body | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-APIRequest -method "Patch" `
                                      -url $newDNSServiceUrl `
                                      -body $body `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response) {
            Write-Error "Failed to create DNS Service."
            return $null
        }else {
            Write-Host "DNS Service '$dnsServiceName' created successfully."
            return @{
                DNSAddress = $dnsServerAddress
                DefaultForwarderZonePath = $defaultForwarderZonePath
            }
        }
    }
    catch {
        Write-Error "Failed to create DNS Service: $_"
        return $null
    }
}

function New-DNS-Address {
    param (
        [string]$dhcpServerAddress
    )

    # Helper function to ensure the new network is within RFC1918 address space
    function Test-RFC1918Address {
        param (
            [uint32]$addressUInt32
        )

        $rfc1918Ranges = @(
            @{ Start = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("10.0.0.0").GetAddressBytes(), 0); End = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("10.255.255.255").GetAddressBytes(), 0) },
            @{ Start = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("172.16.0.0").GetAddressBytes(), 0); End = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("172.31.255.255").GetAddressBytes(), 0) },
            @{ Start = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("192.168.0.0").GetAddressBytes(), 0); End = [BitConverter]::ToUInt32([System.Net.IPAddress]::Parse("192.168.255.255").GetAddressBytes(), 0) }
        )

        foreach ($range in $rfc1918Ranges) {
            if ($addressUInt32 -ge $range.Start -and $addressUInt32 -le $range.End) {
                return $true
            }
        }

        return $false
    }

    # Extract the base network address and subnet mask
    $originalNetwork, $prefixLength = $dhcpServerAddress -split '/'
    $prefixLength = [int]$prefixLength

    # Convert the base network address to an array of bytes
    $baseAddressBytes = [System.Net.IPAddress]::Parse($originalNetwork).GetAddressBytes()

    # Increment the third octet
    $baseAddressBytes[2] = ($baseAddressBytes[2] + 1) % 256

    # Set the fourth octet to 1
    $baseAddressBytes[3] = 1

    # Convert the byte array to an integer
    $newSubnetStartUInt32 = [BitConverter]::ToUInt32($baseAddressBytes, 0)

    # Ensure the new network is within RFC1918 address space
    while (-not (Test-RFC1918Address -addressUInt32 $newSubnetStartUInt32)) {
        $baseAddressBytes[2] = ($baseAddressBytes[2] + 1) % 256
        $newSubnetStartUInt32 = [BitConverter]::ToUInt32($baseAddressBytes, 0)
    }

    # Convert the integer back to a byte array
    $newSubnetStartBytes = [BitConverter]::GetBytes($newSubnetStartUInt32)

    # Convert the byte array back to an IP address string
    $newAddress = [System.Net.IPAddress]::new($newSubnetStartBytes).ToString()

    # Return the new subnet address with the new prefix length
    return "$newAddress"
}