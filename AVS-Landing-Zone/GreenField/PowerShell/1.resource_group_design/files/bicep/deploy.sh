## location to be deployed into
deploymentLocation=northeurope

## bicep Deployment
## Bicep File name
bicepFile=main.bicep
## naming our deployment based on file name and date
deploymentName=${bicepFile}-$(date +"%d%m%Y-%H%M%S")"-deployment"
az deployment sub create -n $deploymentName -l ${deploymentLocation} -c -f $bicepFile 