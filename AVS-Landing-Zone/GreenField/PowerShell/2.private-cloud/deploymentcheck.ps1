# get variables
Write-Output "Reading variables"
$variables = Get-Content ..\variables\variables.json | ConvertFrom-Json


## private cloud variables
$privateCloud = $variables.PrivateCloud
$privateCloudRgName = $privateCloud.resourcegroupname
$privateCloudLocation = $privateCloud.location

## check for Resource Group and only continue if valid
$rgCheck = Get-AzResourcegroup -Name $privateCloudRgName -ErrorAction SilentlyContinue

## if an error occurs, $rgCheck is NOT empty 
if ($null -ne $rgCheck) {

    ## private cloud variables
    $cloudName = $privateCloud.privatecloudname

    ## get private cloud
    $privateCloud = Get-AzVMwarePrivateCloud -ResourceGroupName $privateCloudRgName -Name $cloudName -erroraction silentlycontinue

    ##does private cloud exist?
    if ($null -eq $privateCloud) {
        Write-Host "Private cloud $cloudName does not exist"
        exit 1
    }

    if ($null -ne $privateCloud)
    {
        do {
        $privateCloud = Get-AzVMwarePrivateCloud -ResourceGroupName $privateCloudRgName -Name $cloudName
        $provisioningStatus = $privateCloud.provisioningState
        $timestamp = get-date -Format "dd-MM-yyyy - HH:mm:ss"
        switch ($provisioningStatus) {
            "Building" 
            {
                #write-host "Provisioning status for $cloudName is : " -NoNewline 
                #write-host $provisioningStatus -ForegroundColor Yellow -NoNewline
                #write-host " ($timestamp)"
                $statusMessage = "Provisioning status for $cloudName is : " + $provisioningStatus + " ($timestamp)"
                Write-Output $statusMessage
                Start-Sleep -Seconds 300
            }
            "Succeeded"
            {
                #write-host "Provisioning status for $cloudName is : " -NoNewline 
                #write-host $provisioningStatus -ForegroundColor Green -NoNewline
                #write-host " ($timestamp)"
                $statusMessage = "Provisioning status for $cloudName is : " + $provisioningStatus + " ($timestamp)"
                Write-Output $statusMessage
                break
            }
            Default
            {
                #write-host "Provisioning status for $cloudName is : " -NoNewline 
                #write-host $provisioningStatus -ForegroundColor Red -NoNewline
                #write-host " ($timestamp)"
                Start-Sleep -Seconds 300
                $statusMessage = "Provisioning status for $cloudName is : " + $provisioningStatus + " ($timestamp)"
                Write-Output $statusMessage
            }
        }
        } until (
        $provisioningStatus -ne "Building"
        )
    }
} else {
    $rgMessage = "Resource Group $rgName does not exist"
    #Write-Host "Resource Group $rgName does exist"
    Write-Output $rgMessage
}
