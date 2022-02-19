Get-ChildItem '.\' -Recurse -Include '*.bicep' |% {
    $source = $_.FullName
    if (!($source -like "*\Bicep\Modules\*") -and !($source -like "*/Bicep/Modules/*") -and !($source -like "*CRML*") -and !($source -like "*999-WorkInProgress*")) { 
        $folder = $_.Directory.Parent
        $name = $_.BaseName
        $target = Join-Path $folder "ARM\$($name).deploy.json"
        $targetParams = Join-Path $folder "ARM\$($name).parameters.json"
        $bicepParams = Join-Path $folder "Bicep\$($name).parameters.json"
        Write-Host "Building $name in $($folder.Name)"
        & az bicep build -f "$source" --outfile "$target"
        if (!(Test-Path $targetParams)) {
            Set-Content -Path $targetParams -Value ""
        }
        if ((Get-Content $targetParams).Length -lt 4) {
            Write-Warning "Empty Params found in $($name).parameters.json" 
        }
        if (!(Test-Path $bicepParams)) {
            Copy-Item $targetParams $bicepParams
        }
    }
}