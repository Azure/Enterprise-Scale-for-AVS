function Get-AVS-SDDC-Details {
    param (
        [PSCustomObject]$sddc
    )

    try {
        return @{
            subscriptionId = $sddc.id.split("/")[2]
            resourceGroupName = $sddc.id.split("/")[4]
            sddcName = $sddc.id.split("/")[-1]
            sddcId = $sddc.id
            vCenterUrl = $sddc.properties.endpoints.vcsa
            nsxtUrl = $sddc.properties.endpoints.nsxtManager
        }
    }
    catch {
        Write-Error "Failed to Get SDDC Details: $_"
        return
    }
}