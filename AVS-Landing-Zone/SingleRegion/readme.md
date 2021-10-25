

# AVS Landing Zone: Single Region Deployment

The following is a reference implementation to deploy an AVS Landing Zone in a single region. This reference implementation is ideal for customers that have started their journey with an Enterprise-Scale foundation implementation and are looking to extend this with an AVS landing zone

## Prerequisites

To deploy this landing zone, ensure you have followed all the required steps from the [Getting Started](./GettingStarted.md) section



## What will be deployed?

This reference implementation is designed in a way to deploy a full AVS Private Cloud and necessary components to allow for feature add-ins, connectivity and monitoring as per operational best practices. The intention is to deploy this into a new subscription to be considered as the AVS landing zone, adhering to the Azure Landing Zone guidance. However, this can also be deployed to an existing subscription if required

![ALZ Single Region](../../docs/images/alz-single-region.png)

The following components will be deployed:

| **Resource Type**                | **Resource Group**     | **Resource Name**     |
| -------------------------------- | ---------------------- | --------------------- |
| **AVS Private Cloud**            | ${Prefix}-PrivateCloud | ${Prefix}-SDDC        |
| **Virtual Network**              | ${Prefix}-Network      | ${Prefix}-VNet        |
| **Virtual** **Network  Gateway** | ${Prefix}-Network      | ${Prefix}-GW          |
| **Bastion**                      | ${Prefix}-Jumpbox      | ${Prefix}-bastion     |
| **Jumpbox VM**                   | ${Prefix}-Jumpbox      | ${Prefix}-Jumpbox     |
| **Monitoring**                   | ${Prefix}-Operational  | ${Prefix}-ActionGroup |

Note:  The deployment will ask for a "Prefix" which will be used to name all of5 the deployed resources. The naming of resources is hard coded in the templates, however this can be modified as required prior to deployment

<br/>

## How to deploy this reference implementation

We have a few options available to deploy this AVS Landing zone:

- ARM (Portal): Click on the Deploy to Azure button at the top of this page, this will take you to the portal experience of deploying the ARM template here

- ARM (Template)
- Bicep

<br/>

# Example Deployment Steps (Azure CLI)

1. Clone this repository onto either the Azure Cloud Shell or your local machine
2. Select the template you want to use, for the steps below we will be using the ARM template within [AVS Single Region](https://github.com/shaunjacob/Enterprise-Scale-for-AVS/blob/updatedreadme/AVS-Landing-Zone/SingleRegion/ARM)
3. Modify the `ESLZDeploy.parameters.json` parameters file to define your location, networking, and alert emails
4. Before deploying, confirm the correct subscription is selected using the following command:

```
az account show
```

1. Kick off the AVS deployment using the template & parameters file. You will need to fill in the following arguments:

- The location the deployment metadata will be stored: `-l Location` You can use the `-c` option to validate what resources will be deployed prior to be deploying:

```
az deployment sub create -l AustraliaEast -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```

You can also use `--no-wait` option to kick of the deployment without waiting for it to complete:

```
az deployment sub create -l AustraliaEast -c --no-wait -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```

<br/>

# Confirming Deployment

Private cloud deployment takes around 3-4 hours. Once the deployment has completed it is important to check that the deployment succeeded & the AVS Private Cloud status is "Succeeded". If the Private Cloud fails to deploy, you may need to [raise a support ticket](https://docs.microsoft.com/en-us/azure/azure-vmware/fix-deployment-failures).





# AVS Landing Zone: Single Region Deployment


```
az deployment sub create -n AVSDeploy -l SoutheastAsia -c -f "ESLZDeploy.deploy.json" -p "@ESLZDeploy.parameters.json"
```
