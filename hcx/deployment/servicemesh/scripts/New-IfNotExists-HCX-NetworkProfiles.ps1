. .\Get-HCX-vCenterConfig.ps1
. .\Get-Segment-Details.ps1

function New-IfNotExists-HCX-NetworkProfiles {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword
    )    
    try {
        Write-Host "Checking for existing HCX Network Profiles and creating new if they do not exist..."
        # Define a hashtable to hold network profile IDs
        $networkProfiles = @{}

        # Define an array of network profile types to check
        $networkProfileTypes = @("management", "uplink", "replication", "vmotion")

        # Loop through each type and check if the network profile exists
        foreach ($networkProfileType in $networkProfileTypes) {
            $networkProfile = Get-HCX-NetworkProfiles `
                -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                -hcxConnectorUserName $hcxConnectorUserName `
                -hcxConnectorPassword $hcxConnectorPassword `
                -networkProfileType $networkProfileType

            if ($null -eq $networkProfile) {
                #Create new network profile

                # Select $networkName based on the type
                $networkName = switch ($networkProfileType) {
                    "management" { $managementNetworkName }
                    "uplink"     { $uplinkNetworkName }
                    "vmotion"    { $vmotionNetworkName }
                    "replication"{ $replicationNetworkName }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                # Select start and end IP addresses for the network
                $networkStartIPAddress = switch ($networkProfileType) {
                    "management" { $managementNetworkStartIPAddress }
                    "uplink"     { $uplinkNetworkStartIPAddress }
                    "vmotion"    { $vmotionNetworkStartIPAddress }
                    "replication"{ $replicationNetworkStartIPAddress }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                $networkEndIPAddress = switch ($networkProfileType) {
                    "management" { $managementNetworkEndIPAddress }
                    "uplink"     { $uplinkNetworkEndIPAddress }
                    "vmotion"    { $vmotionNetworkEndIPAddress }
                    "replication"{ $replicationNetworkEndIPAddress }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                # Select gateway IP address and prefix length for the network
                $networkGatewayIPAddress = switch ($networkProfileType) {
                    "management" { $managementNetworkGatewayIPAddress }
                    "uplink"     { $uplinkNetworkGatewayIPAddress }
                    "vmotion"    { $vmotionNetworkGatewayIPAddress }
                    "replication"{ $replicationNetworkGatewayIPAddress }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                $networkPrefixLength = switch ($networkProfileType) {
                    "management" { $managementNetworkPrefixLength }
                    "uplink"     { $uplinkNetworkPrefixLength }
                    "vmotion"    { $vmotionNetworkPrefixLength }
                    "replication"{ $replicationNetworkPrefixLength }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                $networkDNSIPAddress = switch ($networkProfileType) {
                    "management" { $managementNetworkDNSIPAddress }
                    "uplink"     { $uplinkNetworkDNSIPAddress }
                    "vmotion"    { $vmotionNetworkDNSIPAddress }
                    "replication"{ $replicationNetworkDNSIPAddress }
                    default      { throw "Unknown network profile type: $networkProfileType" }
                }

                $networkProfileObjectId = New-HCX-NetworkProfile `
                    -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
                    -hcxConnectorUserName $hcxConnectorUserName `
                    -hcxConnectorPassword $hcxConnectorPassword `
                    -networkProfileType $networkProfileType `
                    -networkName $networkName `
                    -networkStartIPAddress $networkStartIPAddress `
                    -networkEndIPAddress $networkEndIPAddress `
                    -networkGatewayIPAddress $networkGatewayIPAddress `
                    -networkPrefixLength $networkPrefixLength `
                    -networkDNSIPAddress $networkDNSIPAddress                
                    
                if ($networkProfileObjectId) {
                    # Add the created network profile to the hashtable
                    switch ($networkProfileType) {
                        "management" { $networkProfiles.mgmtProfileId = $networkProfileObjectId }
                        "uplink"     { $networkProfiles.uplinkProfileId = $networkProfileObjectId }
                        "vmotion"    { $networkProfiles.vmotionProfileId = $networkProfileObjectId }
                        "replication"{ $networkProfiles.replicationProfileId = $networkProfileObjectId }
                    }
                }
            } else {
                    # Add the existing network profile to the hashtable
                    switch ($networkProfileType) {
                        "management" { $networkProfiles.mgmtProfileId = $networkProfile.objectId }
                        "uplink"     { $networkProfiles.uplinkProfileId = $networkProfile.objectId }
                        "vmotion"    { $networkProfiles.vmotionProfileId = $networkProfile.objectId }
                        "replication"{ $networkProfiles.replicationProfileId = $networkProfile.objectId }
                    }
            }
        }

        return $networkProfiles
    }
    catch {
        Write-Host "Error processing Network Profiles: $_"
    }  
}

function Get-HCX-NetworkProfiles {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$networkProfileType
    )

    try {
        # Define API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "hybridity/api/networks",
            $hcxConnectorServiceUrl
        )

        # Make the request
        $response = Invoke-API -method "GET" `
            -url $apiUrl `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        #Process the response
        if ($response) {
            # Search every array item in $response for .recommendationTags
            foreach ($item in $response) {
                if ($item.recommendationTags -contains $networkProfileType -or `
                    $item.name -contains $networkProfileType) {
                    Write-Host "'$($item.name)' HCX Network Profile for '$networkProfileType' network already exists."
                    return $item
                }
            }
        }

        return $null
    }
    catch {
        Write-Error "Error retrieving Network Profiles: $_"
    }
}

function New-HCX-NetworkProfile {
    param (
        [string]$hcxConnectorServiceUrl,
        [string]$hcxConnectorUserName,
        [SecureString]$hcxConnectorPassword,
        [string]$networkProfileType,
        [string]$networkName,
        [string]$networkStartIPAddress,
        [string]$networkEndIPAddress,
        [string]$networkGatewayIPAddress,
        [int]$networkPrefixLength,
        [string]$networkDNSIPAddress
    )

    try {
        # Get the vCenter configuration
        $hcxvCenterConfig = Get-HCX-vCenterConfig `
            -hcxConnectorMgmtUrl $hcxConnectorMgmtUrl `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword

        if (-not $hcxvCenterConfig) {
            Write-Error "Failed to retrieve HCX vCenter Config."
            return $null
        }

        # Append "/" to the HCX Connector vCenter URL
        $hcxConnectorvCenter =  $hcxvCenterConfig.url
        $hcxConnectorvCenter += "/"

        # Get the segment details for the Network
        $segment = Get-Segment-Details `
            -hcxConnectorvCenter $hcxConnectorvCenter `
            -hcxConnectorUserName $hcxConnectorUserName `
            -hcxConnectorPassword $hcxConnectorPassword `
            -segmentName $networkName

        # Define API endpoint
        $apiUrl = [string]::Format(
            "{0}" +
            "admin/hybridity/api/networks",
            $hcxConnectorServiceUrl
        )

        # Define the body of the request
        $body = @{
            name = $segment.name
            l3TenantManaged= $false
            backings = @(
                @{
                    backingId = $segment.network
                    backingName = $segment.name
                    type = $segment.type
                    vCenterInstanceUuid = $hcxvCenterConfig.vcuuid
                }
            )
            ipScopes = @(
                @{
                    networkIpRanges = @(
                        @{
                            startAddress = $networkStartIPAddress
                            endAddress   = $networkEndIPAddress
                        }
                    )
                    gateway = $networkGatewayIPAddress
                    prefixLength = $networkPrefixLength
                    primaryDns = $networkDNSIPAddress
                }
            )
            mtu = 1500
            recommendationTags = @($networkProfileType)
        }

        # Convert the body to JSON
        $jsonBody = $body | ConvertTo-Json -Depth 10

        # Make the API request
        $response = Invoke-API -method "POST" `
            -url $apiUrl `
            -body $jsonBody `
            -hcxConnectorServiceUrl $hcxConnectorServiceUrl `
            -userName $hcxConnectorUserName `
            -password $hcxConnectorPassword `
            -AuthType "HCX"

        # Process the response
        if ($response -and $response.error -eq $false) {
            Write-Host "Created '$networkProfileType' HCX Network Profile successfully."
            return $response.data.objectId
            
        } else {
            Write-Host "Failed to create '$networkProfileType' HCX Network Profile."
            return $null
        }
    }
    catch {
        Write-Error "Error creating HCX Network Profile: $_"
    }
}
