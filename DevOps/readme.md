# AVS DevOps Guidance

Automation can be utilized to deploy the Azure VMware Solution in multiple ways, from a CLI driven approach to an Infrastructure-as-Code declarative strategy, having a scripted and repeatable deployment methodology is highly recommended for enterprise scale customers. 

This folder contains a series of guides on how to use both the Greenfield and Brownfield templates with CI/CD pipelines including Azure DevOps. While sample implementations are provided, these should be treated as a starting point and modified to meet your requirements.

## Prerequisites

Prior to deploying via CI/CD, it is recommended to have manually deployed any of the templates, so you understand how the template is structured, and how parameters are set. It is also recommended to read all the instructions from the [Getting Started](../GettingStarted.md) section before deploying the Greenfield template.

## DevOps Guides

- [Azure DevOps - Deploying Greenfield Bicep](./AzureDevOps-Bicep/readme.md)