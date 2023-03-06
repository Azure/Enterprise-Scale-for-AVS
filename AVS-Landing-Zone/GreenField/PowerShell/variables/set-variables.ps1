$rootFolder
$variablesPath = $rootFolder + "\variables\variables.json"
$variablesPath
$variables = Get-Content -path $variablesPath | ConvertFrom-Json
$variables
#$variables = Get-Content .\variables\variables.json | ConvertFrom-Json