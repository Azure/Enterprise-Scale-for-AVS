. ./Test-GlobalReach.ps1
. ./Test-ERKeyRedemption.ps1
. ./Test-InternetConnectivity.ps1
. ./Test-ERGateway.ps1
. ./Test-vWAN-ERGateway.ps1
. ./Test-DNS.ps1
. ./Test-DHCP.ps1
function Test-Networking-DesignArea {
    param (
        [SecureString]$token,
        [SecureString]$graphToken,
        [string]$tenant,
        [PSCustomObject]$sddc,
        [System.Object[]]$allgatewayConnections,
        [System.Object[]]$allvWANgateways
    )
    try {
        #Test Global Reach
        Write-Host "Testing Global Reach"
        Test-GlobalReach -token $token -sddc $sddc

        #Test ER Auth Key Redemption
        Write-Host "Testing ER Auth Key Redemption"
        Test-ERKeyRedemption -token $token -sddc $sddc

        #Test Internet Connectivity
        Write-Host "Testing Internet Connectivity"
        Test-InternetConnectivity -token $token -sddc $sddc

        #Test ER Gateway
        Write-Host "Testing ER Gateway Connections"
        Test-ERGateway -token $token -sddc $sddc -allgatewayConnections $allgatewayConnections

        #Test vWAN ER Gateway
        Write-Host "Testing vWAN Connections"
        Test-vWAN-ERGateway -token $token -sddc $sddc -allvWANgateways $allvWANgateways

        # Test DNS
        Write-Host "Testing DNS"
        Test-DNS -token $token -sddc $sddc

        # Test DHCP
        Write-Host "Testing DHCP"
        Test-DHCP -token $token -sddc $sddc
    }
    catch {
        Write-Error "Test Networking Design Area Failed: $_"
        return
    }
}