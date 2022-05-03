# AVS-SERVICEHEALTH-MOTD
This repo is an Azure Function App that injests Service Alerts for Azure VMware Solution and set the Message Of the Daty in vCenter to alert vCenter users that maintenance is on going.
## Usage
1. Setup an Azure Python Function App with vnet networking to a vnet that has access to your AVS instance
2. Create a user managed identity and set the add to run as that user
3. Assign the read privledge on your AVS cloud to the user managed identity
4. Clone or fork this repo
5. Setup the Function App Deployment Center setting and integrate them into your github repo
6. Build the project
7. Setup a Service Alert for AVS to run your new function app
## Outputs
The function will be called by Service Health Alert and will set the MOTD on vCenter to alert users of the maintenance