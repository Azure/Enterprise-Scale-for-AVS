# Configure Dashboard

It is crucial to monitor the resource utilization in order to understand what is happening within your Private Cloud. This scenario gives you a basic dashboard template to monitor CPU, Memory, and Disk utilization within a specified Private Cloud.

## Prerequisites

* AVS Private Cloud up and running.

* (Optional) An Express Route Gateway - please collect the resourceid from the Express Route GW connection  <https://docs.microsoft.com/en-us/azure/expressroute/expressroute-howto-add-gateway-portal-resource-manager> from your hub vNet. 

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Dashboard -c -f "AVSDashboard.bicep" -p "@AVSDashboard.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Dashboard -c -f "AVSDashboard.deploy.json" -p "@AVSDashboard.parameters.json"
```

### Terraform

Edit `terraform.tfvars` file with appropriate settings, then:

```bash
terraform plan
terraform apply
```

## Post-deployment Steps

* Navigate to Dashboard page in Azure Portal. Clicking the down arrow in the top left corner should allow you to switch to the newly created dashboard.

## Next Steps

[Configure Alerts](../AVS-Utilization-Alerts/)
