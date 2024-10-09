
# Import functions
. .\Install-RequiredModule.ps1
. .\Connect-To-Azure.ps1
. .\Get-Azure-Token.ps1
. .\Invoke-APIRequest.ps1
. .\Get-vCenter-Credentials.ps1
. .\Get-AVS-Endpoints.ps1
. .\New-IfNotExist-PublicIP.ps1
. .\New-IfNotExist-Tier1GW.ps1
. .\New-IfNotExist-DNS.ps1
. .\New-IfNotExist-Segment.ps1
. .\New-IfNotExist-IPSecVPNService.ps1
. .\New-IfNotExist-LocalEndpoint.ps1
. .\New-IfNotExist-IPSecSessionPolicyBased.ps1
. .\New-IfNotExist-NATrule.ps1
. .\Get-AVS-VMs.ps1

function Main {
    try {
        # Define the Azure VMware Solution SDDC details
        $tenantId = "27eda52d-06a5-4e9f-bd76-1a062e47aba0"
        $subscriptionId = "d52f9c4a-5468-47ec-9641-da4ef1916bb5"
        $AVSSDDCresourceGroupName = "AvsForArcPOC"
        $privateCloudName = "AVsforArc"
        $publicIpName = "AVS-VPN-Public-IP"
        $numberOfPublicIPs = 1
        $tier1GatewayName = "maksh-T1-gateway-vpn"
        $dnsServiceName = "maksh-dns-service-vpn"
        $dhcpProfileName = "maksh-DHCP-2"
        $segmentName = "maksh-vpn-segment"
        $ipSecVpnServiceName = "maksh-ipsec-vpn"
        $ipSecVpnLocalEndpointName = "maksh-ipsec-vpn-lep"
        $ipSecVpnSessionName = "maksh-ipsec-vpn-session"
        $remoteGatewayIP = "4.174.250.100"
        $remoteNetwork = "192.168.0.32/29"
        $ipsForNatRules = @()

        # Check and Install Powershell Modules
        Install-RequiredModule -moduleName Az
        Install-RequiredModule -moduleName AzureRM.Profile

        # Add User Agent
        [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("pid-94c42d97-a986-4d59-a0e6-6cd5aea77442")
        
        # Authenticate to Azure
        Connect-To-Azure -tenantId $tenantId -subscriptionId $subscriptionId

        # Get the access token for Azure API Calls
        $token = Get-Azure-Token
        
        # Get the AVS credentials
        $credentials = Get-vCenter-Credentials -token $token

        # Get the AVS endpoints
        $endpoints = Get-AVS-Endpoints -subscriptionId $subscriptionId `
                                       -resourceGroupName $AVSSDDCresourceGroupName `
                                       -sddcName $privateCloudName `
                                       -token $token

        # Get the AVS VMs
        # Get-AVS-VMs -avsVcenter $endpoints.vCenter `
        #            -avsvCenteruserName $credentials.vCenterUsername `
        #            -avsvCenterpassword $credentials.vCenterPassword

        # Check if the Public IP already exists and create it if it does not
        $publicIP = New-IfNotExist-PublicIP -subscriptionId $subscriptionId `
                           -resourceGroupName $AVSSDDCresourceGroupName `
                           -privateCloudName $privateCloudName `
                           -publicIpName $publicIpName `
                           -numberOfPublicIPs $numberOfPublicIPs `
                           -token $token
        
        $ipsForNatRules += $publicIP + "-Internet"                           
        
        # Check if the Tier1 Gateway already exists and create it if it does not
        $dhcpProfile = New-IfNotExist-Tier1GW -avsnsxTmanager $endpoints.NSXManager `
                                         -nsxtUserName $credentials.nsxtUsername `
                                         -nsxtPassword $credentials.nsxtPassword `
                                         -tier1GatewayName $tier1GatewayName `
                                         -dhcpProfileName $dhcpProfileName

        $ipsForNatRules += $dhcpProfile.DHCPServer_Address + "-DHCP"

        # Check if the DNS already exists and create it if it does not
        $dnsInfo = New-IfNotExist-DNS -avsnsxTmanager $endpoints.NSXManager `
                            -nsxtUserName $credentials.nsxtUsername `
                            -nsxtPassword $credentials.nsxtPassword `
                            -tier1GatewayName $tier1GatewayName `
                            -dnsServiceName $dnsServiceName `
                            -dhcpServerAddress $dhcpProfile.DHCPServer_Address `

        $ipsForNatRules += $dnsInfo.DNSAddress + "-DNS"

        # Check if the Segment already exists and create it if it does not
        $segmentAddress = New-IfNotExist-Segment -avsnsxTmanager $endpoints.NSXManager `
                                        -nsxtUserName $credentials.nsxtUsername `
                                        -nsxtPassword $credentials.nsxtPassword `
                                        -tier1GatewayName $tier1GatewayName `
                                        -segmentName $segmentName `
                                        -dnsServerAddress $dnsInfo.DNSAddress `
                                        -dhcpProfilePath $dhcpProfile.DHCPProfile_Path

        $ipsForNatRules += $segmentAddress + "-Segment"

        # Check if the IPSec VPN Service already exists and create it if it does not
        New-IfNotExist-IPSecVPNService -avsnsxTmanager $endpoints.NSXManager `
                                       -nsxtUserName $credentials.nsxtUsername `
                                       -nsxtPassword $credentials.nsxtPassword `
                                       -tier1GatewayName $tier1GatewayName `
                                       -ipSecVpnServiceName $ipSecVpnServiceName

        # Check if the Local Endpoint already exists and create it if it does not
        $ipSecVpnLocalEndpointPath = New-IfNotExist-LocalEndpoint -avsnsxTmanager $endpoints.NSXManager `
                                    -nsxtUserName $credentials.nsxtUsername `
                                    -nsxtPassword $credentials.nsxtPassword `
                                    -tier1GatewayName $tier1GatewayName `
                                    -vpnServiceName $ipSecVpnServiceName `
                                    -localEndpointName $ipSecVpnLocalEndpointName `
                                    -localEndpointIp $publicIP

        # Check if the IPSec Session already exists and create it if it does not
        New-IfNotExist-IPSecSession-PolicyBased -avsnsxTmanager $endpoints.NSXManager `
                                   -nsxtUserName $credentials.nsxtUsername `
                                   -nsxtPassword $credentials.nsxtPassword `
                                   -tier1GatewayName $tier1GatewayName `
                                   -vpnServiceName $ipSecVpnServiceName `
                                   -localEndpointPath $ipSecVpnLocalEndpointPath `
                                   -remoteGatewayIP $remoteGatewayIP `
                                   -localAddress $segmentAddress `
                                   -remoteAddress $remoteNetwork `
                                   -sessionName $ipSecVpnSessionName

        # Check if the NAT Rule already exists and create it if it does not
        New-IfNotExist-NATRule -avsnsxTmanager $endpoints.NSXManager `
                              -nsxtUserName $credentials.nsxtUsername `
                              -nsxtPassword $credentials.nsxtPassword `
                              -ipsForNatRules $ipsForNatRules

    } catch {
        Write-Error "An error occurred: $_"
        return
    }
}

# Call the main function
Main