# 001-AVS-PrivateCloud
Status: Awaiting PG Signoff

## Prerequisites

Ensure to check following prerequisites before starting the deployment process.

1. Azure VMware Solution host quota is approved for the Azure subscription.

2. Azure Account associated with the user or service principal has contributor permissions on Azure subscription.

3. Do not allow standing access to user or service principal to be used for initiating deployment. Use [Azure Active Directory Privileged Identity Management (PIM)](https://docs.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure) to request Just-In-Time access for starting the deployment process.

## During the deployment

Run following command.

```
az group create -n AVS-RG -l SoutheastAsia

az deployment group create -g AVS-RG -l SoutheastAsia -c -f "PrivateCloud.deploy.json" -p "@PrivateCloud.parameters.json"
```

Depending upon the region and size of the cluster, deployment process may take upto 2 hours.

## Post-deployment Steps

Ensure that status of deployment is "Succeeded" by navigating to "Deployment" tab of the Azure Resource Group used for starting the deployment.

## Next Steps

[Generate Auth Key](../002-AVS-ExRConnection-GenerateAuthKey/readme.md)
