## Variables

$tempFolder = "C:\temp1"
$openSSLFilePath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
$openSSLUrl = "https://slproweb.com/download/Win64OpenSSL-3_0_8.msi"
$openSSLLocalFileName = "Win64OpenSSL-3_0_8.msi"
$vcredistx86downloadurl = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
$vcredistx86installerfilename = "vc_redist.x86.exe"
$vcredistx64downloadurl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$vcredistx64installerfilename = "vc_redist.x64.exe"

## Pre-reqs script
## Script

## SNIPPET 1 - Install VCRedist and OpenSSL

if (!(Test-Path $tempFolder))
{
    New-Item -ItemType Directory -Path $tempFolder
}

write-output "Installing VCRedist x86 - assuming NOT installed"
$vcredistx86FilePath = $tempFolder+"\"+$vcredistx86installerfilename
Invoke-WebRequest -Uri $vcredistx86downloadurl -OutFile $vcredistx86FilePath
Invoke-Expression -Command "$vcredistx86FilePath /passive"
start-sleep 30
write-output "VCRedist x86 installed"

write-output "Installing VCRedist 64 - assuming NOT installed"
$vcredistx64FilePath = $tempFolder+"\"+$vcredistx64installerfilename
Invoke-WebRequest -Uri $vcredistx64downloadurl -OutFile $vcredistx64FilePath
Invoke-Expression -Command "$vcredistx64FilePath /passive"
start-sleep 30
write-output "VCRedist x64 installed"

if (Test-Path $openSSLFilePath)
{
    write-output "OpenSSL exists"
} else {
    write-output "OpenSSL does not exist"
    write-output "Installing OpenSSL"
    $openSSLLocalFilePath = $tempFolder+"\"+$openSSLLocalFileName
    Invoke-WebRequest -Uri $openSSLUrl -OutFile $openSSLLocalFilePath
    msiexec -i $openSSLLocalFilePath /passive
    write-output "Please wait for the installation to complete before continuning"
}

## SNIPPET 2 - Get Certs from DCs

$remoteComputers = "dc1","dc2"
foreach ($computer in $remoteComputers)
{
    $port = "636"
    $output =  echo "1" | & $openSSLFilePath "s_client" "-connect" "$computer`:$port" "-showcerts" | out-string
    $Matches = $null
    $cn = $output -match "0 s\:CN = (?<cn>.*?)\r\n"
    $cn = $Matches.cn
    $Matches = $null
    $certs = select-string -inputobject $output -pattern "(?s)(?<cert>-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----)" -allmatches
    $cert = $certs.matches[0]
    $certExportFile = $tempFolder+"\"+($computer.split(".")[0])+".cer"
    $cert.Value | Out-File $certExportFile -Encoding ascii
}

## SNIPPET 3 - Create Storage Account

## Do you have Azure Module installed?
if (Get-Module -ListAvailable -Name Az.Storage)
{ write-output "Module exists"
} else {
    write-output "Module does not exist"
    write-output "Installing Module"
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name Az.Storage -Scope CurrentUser -Force -AllowClobber
}

## create storage account
$storageAccountRgName = "" # ResourceGroupName for Storage account
$storageAccountLocation = "" # Location for Resource Group
$storageAccountName = "" # Storage Account Name

## Storage account variables
## create storage account
$saCheck = Get-AzStorageAccount -ResourceGroupName $storageAccountRgName -Name $storageAccountName -ErrorAction SilentlyContinue
if ($null -eq $saCheck)
{
    Write-Output "Please create the storage account as per storage-services\deploy-storageaccounts.ps1"
} else {
    write-output "Storage Account already exists"
}


## SNIPPET 4 - Create Container and upload certs
## create container
$containerName = "" # Name of the container

$certs = Get-ChildItem -Path $tempFolder -Filter *.cer
$storageContext = (Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageAccountRgName).Context
foreach ($item in $certs)
{
    $localFilePath = $item.FullName
    $azureFileName = $localFilePath.Split('\')[$localFilePath.Split('\').count-1]
    Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageAccountRgName | Get-AzStorageContainer -Name $containerName | Set-AzStorageBlobContent -File $localFilePath -Blob $azureFileName
}

## SNIPPET 5 - Create SAS Token

## create SAS token
$containerName = $storageAccounts.ldaps.containername
$blobs = Get-AzStorageBlob -Container $containerName -Context $storageContext | Where-Object {$_.name -match ".cer"}
foreach ($blob in $blobs)
{
    $StartTime = Get-Date
    $EndTime = $startTime.AddHours(24.0)
    $sasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $blob.name -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $storageContext -FullUri
    #$sasToken
    write-host "SASToken created: $sasToken"
}