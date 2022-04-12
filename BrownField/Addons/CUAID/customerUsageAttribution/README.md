# Module: PID

This module creates a blank deployment which will be called from other modules. The purpose of this deployment is to create a deployment name to be used for Azure [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution). To disable this, please see [How to disable Telemetry Tracking Using Customer Usage Attribution (PID)](https://github.com/Azure/ALZ-Bicep/wiki/CustomerUsage)

This module does not deploy any resources

## Parameters

This module does not require any inputs

| Parameter | Type | Default | Description | Requirement | Example |
| --------- | ---- | ------- | ----------- | ----------- | ------- |


## Outputs

The module does not generate any outputs

| Output | Type | Example |
| ------ | ---- | ------- |

## Deployment

This module is intended to be called from other modules as a reusable resource. 

## Module PID Value Mapping

The following are the unique ID's (also known as PIDs) used in each of the modules.

| Module Name                                | PID                                    |
| ------------------------------------------ | -------------------------------------- |
| HCX                                        | `ccdff80c-722d-42b7-8bd2-66aba33cba02` |
| SRM                                        | `c542e61c-1907-483f-9e18-76f5b85eee0a` |
| AVS-Dashboard                              | `6a449623-a5df-43f6-8df0-9b32dc2df958` |
| AVS-Service-Health                         | `a182f0f1-a209-42fd-aa05-e12bda423653` |
| AVS-Utilization-Alerts                     | `6f7b68e9-1179-4853-9dfe-1a4f793b9893` |
| AVS-to-AVS-CrossRegion-GlobalReach         | `1593acc2-6932-462b-af58-28f7fa9df52d` |
| AVS-to-AVS-SameRegion                      | `08d3edb1-3d70-4c0f-ab9f-f491b4a8d737` |
| AVS-to-OnPremises-ExpressRoute-GlobalReach | `8fb78b9c-973d-45d1-bd35-fcad3c00e09e` |
| AVS-to-VNet-ExistingVNet                   | `9dd111b1-82f0-4104-bcf9-18b777f0c78f` |
| AVS-to-VNet-NewVNet                        | `938cd838-e22a-47da-8a6f-bdda923e3edb` |
| ExpressRoute-to-VNet                       | `174ca090-c796-4183-bc1f-ac6578e81d39` |
| AVS-PrivateCloud-WithHCX                   | `fe003615-ca8e-412f-8091-43e1e42ebfd8` |
| AVS-PrivateCloud                           | `99f18c8b-1767-4302-9cee-ecc0d135dd52` |