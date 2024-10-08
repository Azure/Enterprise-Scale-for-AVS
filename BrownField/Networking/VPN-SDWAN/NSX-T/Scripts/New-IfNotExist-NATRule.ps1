function New-IfNotExist-NATrule {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [array]$ipsForNatRules
    )
    

    #Get all NAT rules
    $natRules = Get-NATRules -avsnsxTmanager $avsnsxTmanager `
                             -nsxtUserName $nsxtUserName `
                             -nsxtPassword $nsxtPassword `
                             -tier1GatewayName $tier1GatewayName

    #Extract the Segment IPs from the array
    $sourceIP = $ipsForNatRules | Where-Object { $_.split("-")[-1] -eq "Segment" } | ForEach-Object {
        $ipParts = $_.split("-")[0].Split(".")
        $ipParts[3] = "0"
        ($ipParts -join ".") + "/24"
    }

    foreach ($ipNatrule in $ipsForNatRules) {
        $ip = $ipNatrule.split("-")[0]
        $service = $ipNatrule.split("-")[-1]

        if ($service -eq "DHCP") {
            $ip = "$($ip.split(".")[0..2] -join ".").0/24"
        }

        if ($service -ne "Segment") {
            $natRule = Get-NATRule -natRules $natRules `
                       -service $service `
                       -sourceIP $sourceIP `
                       -destinationIP $ip

            if ($null -eq $natRule) {
            switch ($service) {
                "DNS" {
                $natRuleName = "No-SNAT-DNS"
                $action = "NO_SNAT"
                $sequenceNumber = 10
                }
                "DHCP" {
                $natRuleName = "No-SNAT-DHCP"
                $action = "NO_SNAT"
                $sequenceNumber = 20
                }
                default {
                $natRuleName = "SNAT-Internet"
                $action = "SNAT"
                $sequenceNumber = 100
                }
            }

            Write-Host "Creating NAT Rule for $service"
            $natRule = New-NATRule -avsnsxTmanager $avsnsxTmanager `
                           -nsxtUserName $nsxtUserName `
                           -nsxtPassword $nsxtPassword `
                           -tier1GatewayName $tier1GatewayName `
                           -natRuleName $natRuleName `
                           -action $action `
                           -sourceNetwork $sourceIP `
                           -translatedNetwork $ip `
                           -destinationNetwork $ip `
                           -sequenceNumber $sequenceNumber
            }
        }
    }                             
}

function Get-NATRule {
    param(
        [array]$natRules,
        [string]$service,
        [string]$sourceIP,
        [string]$destinationIP
    )

    # Filter $natRules based on conditions
    $natRule = $natRules | Where-Object { 
        $_.primary -and $_.primary.source_network -ieq $sourceIP -and
        (($service -ieq "Internet" -and $_.primary.translated_network -ieq $destinationIP) -or
        ($service -ine "Internet" -and $_.primary.destination_network -ieq $destinationIP))
    }
    
    if ($null -ne $natRule) {
        Write-Host "$service NAT Rule already exists."
    }

    return $natRule
}

function Get-NATRules {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName
    )

    $natRulesUrl = "$avsnsxTmanager/policy/api/v1/search/aggregate?" +
                        "sort_by=sequence_number&sort_ascending=true&page_size=50"

    $body = @{
        primary = @{
            resource_type = "PolicyNatRule"
            filters = @(
                @{
                    field_names = "parent_path"
                    value = "`"/infra/tier-1s/maksh-T1-gateway-vpn/nat/USER`""
                    case_sensitive = $true
                }
            )
        }
        related = @(
            @{
                resource_type = "Service"
                join_condition = "path:service"
                alias = "Service"
            },
            @{
                resource_type = "Tier0Interface OR Tier1Interface OR Tier0InterfaceGroup OR Tier1InterfaceGroup OR PolicyLabel OR Tier1 OR RouteBasedIPSecVpnSession"
                join_condition = "path:scope"
                alias = "Tier0Interface OR Tier1Interface OR Tier0InterfaceGroup OR Tier1InterfaceGroup OR PolicyLabel OR Tier1 OR RouteBasedIPSecVpnSession"
            }
        )
    }

    $body = $body | ConvertTo-Json -Depth 10

    $response = Invoke-APIRequest -method "POST" `
                                      -url $natRulesUrl `
                                      -body $body `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

    if ($null -eq $response -or $null -eq $response.results) {
        return $null
    }else {
        return $response.results
    }
}

function New-NATRule {
    param(
        [string]$avsnsxTmanager,
        [string]$nsxtUserName,
        [SecureString]$nsxtPassword,
        [string]$tier1GatewayName,
        [string]$natRuleName,
        [string]$action,
        [string]$sourceNetwork,
        [string]$translatedNetwork = $null,
        [string]$destinationNetwork = $null,
        [int]$sequenceNumber
    )

    $natRuleUrl = [string]::Format(
        "$avsnsxTmanager/policy/api/v1/infra/tier-1s/{0}" +
        "/nat/USER/nat-rules/{1}",
        $tier1GatewayName,
        $natRuleName)

    $body = @{
        action = $action
        enabled = $true
        display_name = $natRuleName
        source_network = $sourceNetwork
        firewall_match = "MATCH_INTERNAL_ADDRESS"
        sequence_number = $sequenceNumber
        id = $natRuleName
    }

    # Update Body to have destination network if action is No_SNAT
    if ($action -eq "NO_SNAT") {
        $body.destination_network = $destinationNetwork
    }elseif ($action -eq "SNAT") {
        $body.translated_network = $translatedNetwork
    }

    $body = $body | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-APIRequest -method "Put" `
                                      -url $natRuleUrl `
                                      -body $body `
                                      -avsnsxtUrl $avsnsxTmanager `
                                      -avsnsxtUserName $nsxtUserName `
                                      -avsnsxtPassword $nsxtPassword

        if ($null -eq $response) {
            Write-Error "Failed to create NAT Rule '$natRuleName'."
        }else {
            Write-Host "Created NAT Rule '$natRuleName'."
        }
    } catch {
        Write-Error "Failed to create NAT Rule '$natRuleName': $_"
    }

    return $natRule
}