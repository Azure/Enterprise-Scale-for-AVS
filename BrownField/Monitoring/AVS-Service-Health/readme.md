# Configure Service Health Alerts

Any updates or impacting events for AVS are published via Service Health, it is critical to monitor this for any notifications. This scenario will setup service health notifications for a given set of email addresses. Action owners will receive email notifications if a service health event is published.

This scenario is also included in the [AVS-Utilization-Alerts](../AVS-Utilization-Alerts) scenario.

## Prerequisites

* AVS Private Cloud up and running.

* A list of email address(es) who will receive Service Health Alerts.

## Deployment Steps

* Update the parameter values in appropriate parameter file.

* Run one of the following scripts.

### Bicep

```azurecli-interactive
cd Bicep

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Deployment -c -f "AVSMonitor.bicep" -p "@AVSMonitor.parameters.json"
```

### ARM

```powershell
cd ARM

az deployment group create -g AVS-Step-By-Step-RG -n AVS-Monitoring-Deployment -c -f "AVSMonitor.deploy.json" -p "@AVSMonitor.parameters.json"
```

### Terraform

Edit `terraform.tfvars` file with appropriate settings, then:

```bash
terraform plan
terraform apply
```

## Post-deployment Steps

* Navigate to Azure Monitor service in Azure Portal. Click "Alerts" tab and navigate to "Manage alert rules". Newly created alert - *AVS-ServiceHealth-* - should be listed with status as "Enabled".

## Next Steps

[Setup Utilization Alerts](../AVS-Utilization-Alerts)
