Get-ChildItem '.\' -Recurse -Include '*.bicep' -Exclude 'Module-*' |% {
    $source = $_.FullName
    $folder = $_.Directory.Parent
    $name = $_.BaseName
    $target = Join-Path $folder "ARM\$($name).deploy.json"
    $targetParams = Join-Path $folder "ARM\$($name).parameters.json"
    Write-Host "Building $name in $($folder.Name)"
    & az bicep build -f "$source" --outfile "$target"
    if (!(Test-Path $targetParams)) {
        Set-Content -Path $targetParams -Value ""
    }
    if ((Get-Item $targetParams).Length -lt 4) {
        Write-Warning "Empty Params found in $($name).parameters.json" 
    }
}