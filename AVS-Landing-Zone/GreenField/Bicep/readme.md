# Deployment Steps (AZ CLI)

1. Clone this repository onto either the Azure Cloud Shell or local machine
2. Modify the `ESLZDeploy.parameters.json` parameters file to define desired location, networking, and alert emails
3. Before deploying, confirm the correct subscription is selected using the following command:

```
az account show
```

4. Kick off the AVS deployment using the template & parameters file. You will need to fill in the following arguments:

The location the deployment metadata will be stored: `-l Location` You can use the `-c` option to validate what resources will be deployed prior to be deploying:

```
az deployment sub create -l AustraliaEast -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```

You can also use `--no-wait` option to kick of the deployment without waiting for it to complete:

```
az deployment sub create -l AustraliaEast -c --no-wait -f "ESLZDeploy.deploy.bicep" -p "@ESLZDeploy.parameters.json"
```

<br/>

# Confirming Deployment

Private cloud deployment takes around 3-4 hours. Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).

