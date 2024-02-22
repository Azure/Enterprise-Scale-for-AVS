# Deploy a pair of logstash VMs and configure AVS custom syslog filtering

## Table of contents

- [Deploy a pair of logstash VMs and configure AVS custom syslog filtering](#deploy-a-pair-of-logstash-vms-and-configure-avs-custom-syslog-filtering)
  - [Table of contents](#table-of-contents)
  - [Sample Details](#sample-details)
  - [Automation implementation](#automation-implementation)
  - [Appendix](#appendix)


## Sample Details

This sample demonstrates the configuration and use of a module that enables custom filtering of the syslog data prior to ingesting it into a log analytics workspace. It takes as input naming and tag information as well as the resource ID's for the private cloud being monitored as well as the subnet where the logstash VMs will be deployed. The module creates the following resources:

| Resource       | Usage                                                 |
| ------------------- | ------------------------------------------------------------ |
| Resource Group           | Resource container for the log filter related resources |
| Event Hub Related Resources | An Event Hub Namespace with an Event Hub, Consumer Group, Authorization Rules, and a storage account for use by the logstash event hub plugin |
| Azure Monitor Related Resources | A Log Analytics Workspace, Data Collection Endpoint, and Data Collection Rules configured to use a custom table |
| Service Principal related artifacts | An Azure AD application, Service Principal and associated secrets
| Logstash related resources | Two Ubuntu 20.04 VMs, a key vault for storing the vm related secrets, and a set of templates for configuring logstash |
| Private Cloud configuration | A diagnostic setting on the private cloud the configures the syslog to go the eventhub for processing |

The overall architecture is rather simple.  The private cloud sends the full syslog to an Event Hub.  A pair of VMs are configured to run logstash as a service and the terraform leverages a cloud-init template file to install and configure logstash.  Logstash uses an input plugin for EventHub to connect to the event hub and get the eventhub data.  From there a series of json and mutate filters are used to drop info level logs from the input stream.  It then uses the Sentinel plugin to send the data to a custom log analytics table in a new log analytics workspace. The eventhub plugin uses a storage account as a witness which allows for multiple processing VMs to share the workload and provide redundancy.

[(Back to top)](#table-of-contents)

## Automation implementation

This sample is a root module that calls several child modules included in the modules and scenarios subdirectories of the terraform directory.  This root module inputs the deployed values directly in the submodule calls, so to change the deployment behavior, modify the values directly in the main.tf file. This module also includes a sample providers file that can be modified to fit your specific environment.

To deploy this module, ensure you have a deployment machine that meets the pre-requisites for Azure Deployments with terraform. Clone this repo to a local directory on the deployment machine.  Update the sample_config.auto.tfvars variable values and make any updates to the providers sample file backend block and uncomment them if needed.

Execute the terraform init/plan/apply workflow to execute the deployment.

[(Back to top)](#table-of-contents)

## Appendix


[(Back to top)](#table-of-contents)