function Get-DHCP-NSXT {
    param(
        [SecureString]$token,
        [PSCustomObject]$sddc
    )

    try {
        # Get AVS SDDC details
        $sddcDetails = Get-AVS-SDDC-Details -sddc $sddc

        # Get the NSX-T credentials
        $credentials = Get-AVS-Credentials -token $token -sddc $sddc

        # Define the API URL
        $apiUrl = [string]::Format(
            "{0}" +
            "policy/api/v1/search/aggregate?page_size=50&cursor=0&sort_by=display_name&sort_ascending=true",
            $sddcDetails.nsxtUrl
        )

        # Define the body
        $body = @{
            primary = @{
                resource_type = "DhcpRelayConfig OR DhcpServerConfig"
            }
            related = @(
                @{
                    resource_type = "Tier0"
                    join_condition = "dhcp_config_paths:path"
                    alias = "dhcp_tier0"
                },
                @{
                    resource_type = "PolicyEdgeCluster"
                    join_condition = "path:edge_cluster_path"
                    alias = "edge_cluster"
                },
                @{
                    resource_type = "PolicyEdgeNode"
                    join_condition = "path:preferred_edge_paths"
                    alias = "PolicyEdgeNode"
                },
                @{
                    resource_type = "Tier1"
                    join_condition = "dhcp_config_paths:path"
                    alias = "dhcp_tier1"
                },
                @{
                    resource_type = "Segment"
                    join_condition = "dhcp_config_path:path"
                    alias = "Segment"
                },
                @{
                    resource_type = "Tier0Interface OR Tier1Interface"
                    join_condition = "dhcp_relay_path:path"
                    alias = "dhcp_interfaces"
                }
            )
        }

        $body = $body | ConvertTo-Json -Depth 10

        # Make the request
        $response = Invoke-APIRequest -method "POST" `
            -url $apiUrl `
            -avsnsxtUserName $credentials.nsxtUsername `
            -avsnsxtPassword $credentials.nsxtPassword `
            -body $body

        # Return the response
        return $response

    }
    catch {
        Write-Error "NSX-T DHCP Test failed: $_"
    }
}