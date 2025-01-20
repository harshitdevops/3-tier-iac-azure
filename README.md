# Building a 3-Tier application infrastrcuture within Azure on Terraform

## Objective
This project aims to design and implement a secure, scalable multi-tier application that focuses on security and availability.

- Availability: Deployed in seperate availbility zones to reduce redundancy and enbale fault tolerance.
- Security: Specific segmentation of the network into separate subnets to help control traffic flow.
- Resiliency: Use Azure Load Balancer to distribute incoming traffic and ensure high availability.
- Management: Implementation of Azure Key Vault to securely manage access to database and storage account.

## Architectural overiview
The architecture comprises of 2 Service plans, 1 for frontend and another for backend, these also connect to a load balancer to ensure the traffic is manageable and maintainable. In addition, a virtual network to encompass and secure the applications and storage accounts, which additional subnets to for each app. Also the storage account for the information from the backend applications and Application insights to monitor the activity from both Frontend and Backend apps. 
This is then sent to log analytics to raise to raise any alerts if necessary. These are also sent to Azure SQL to for safe storage.


![](./assets/architecture.gif)

## Terraform files Explained in Detail

**Provider**: - [Provider](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/providers.tf) - 
    Hashcorp minimum version 4.0.1. This file defines the Azure provider required for this project, using the azurerm provider version 4.0.1. It provisions a storage account and container to securely store Terraform's state file, ensuring that infrastructure changes are tracked. Additionally, the provider configuration includes a subscription ID, allowing Terraform to interact with Azure resources under the correct account.

**AppServicePlan** - [appserviceplan.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/appserviceplan.tf) - 
      This file configures two separate Azure App Service Plans: one for the frontend and one for the backend. Both plans use a Linux OS and the Basic "B1" SKU, Premium app service plan sku supports Availability Zones for scaling and redundancy. Dependencies are set to ensure that the app service plans are created only after the required subnets are provisioned.

**AzureWebsite** - [azurewebsite.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/azurewebsite.tf) - 
      This file defines two primary resources: the frontend Linux web app and the backend Function App. The web app uses Node.js (version 20 LTS) and is secured by HTTPS-only traffic. It is also linked to Application Insights for monitoring. The backend Function App, built in Python (version 3.12), is secured by Virtual Network integration and restricts access to the frontend subnet. Both apps use system-assigned identities to access other Azure resources.

**Database** - [database.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/database.tf)
      This file manages an Azure SQL Server and database. A random complex password is generated to ensure security. Additionally, a virtual network rule is created to restrict access to the backend subnet only. The file also creates a SQL database and defines its parameters, including size, collation, and environment tags.

**KeyVault** - [keyvault.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/keyvault.tf)
      This file provisions an Azure Key Vault, enabling disk encryption and setting retention policies for deleted secrets. It configures access policies, granting specific users and applications permissions to access keys and secrets. Additionally, Key Vault logging is enabled using Azure Monitor Diagnostic Settings.

**Logging** - [logging.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/logging.tf)
      This file creates an Azure Log Analytics workspace for storing diagnostic logs and Application Insights to monitor the performance of the frontend web app and backend Function App. Both resources enable detailed telemetry collection for analysis and diagnostics.
      
**Main** - [main.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/main.tf)
      This file defines the Azure Resource Group where all other resources are provisioned. Tags are also added for environment and team categorization.

**Outputs** - [outputs.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/outputs.tf)
      This file provides output values that are useful for interacting with the infrastructure. It outputs the resource group ID, the URLs for both the frontend and backend apps.
    
**Variables** - [variables.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/variables.tf)
      This file declares variables used across other Terraform files, such as the resource_group_name and location. It allows for easy customization by centralizing configuration values.

**Vnet** - [vnet.tf](https://github.com/harshitdevops/3-tier-iac-azure/blob/main/vnet.tf)
      This file creates an Azure Virtual Network and subnets for the frontend and backend. The subnets are configured with service endpoints, allowing secure communication between web services and the SQL database. Delegations for each subnet are defined to manage which services can connect to the subnets.

