# Azure VMware Solution Well-Architected Framework: Security


This section covers how to secure and protect workloads running in the. Azure VMware Solution (AVS) by implementing various measures to protect the infrastructure, data, and applications. This entails having a holistic approach that aligns with the organization's core priorities. 


## Infrastructure Security


This section refers to protecting underlying infrastructure components through regular updates, applying patches, and monitoring for security vulnerabilities or threats.

### Managing Compliance and Governance

#### Impact: _Security_, _Operational Excellence_
It's important to easily see and detect which servers are following out of compliance. Azure Arc is a service that allows you to extend Azure management and Azure services to on-premises or multi-cloud environments. By providing
centralized management and governance for servers, Azure ARC, gives you a single pane glass view to applying updates and hotfixes in Azure, On-Premises, and AVS for a consistent management experience. 

### Recommendations 
- Configure Azure VMware Solution guest VMs as Azure Arc-enabled Servers by using one of the following methods. 

- Azure Connected Machine agent deployment options 

- Deploy Arc for Azure VMware Solution (Preview) 

- Use Azure Policy for Azure Arc-enabled Servers to audit and enforce security controls on Azure VMware Solution guest VMs. 

#### Assessment Questions 
- What tools are in place for patch management and system upgrades? _(new)_

### Protecting the Guest OS
#### Impact: _Security_ 

The operating system is susceptible to vulnerabilities if not patched and regularly updated, which can put your entire platform at risk. Patching regularly combined with an endpoint protection solution helps prevent 
common attack vectors that target the OS and keep your systems up to date. Regularly performing  vulnerability scans and assessments will identify and remediate security weaknesses or vulnerabilities. 

- Azure Defender for Cloud has unique tools that provide advanced threat protection across your Azure VMware Solution and on-premises virtual machines (VMs) 
including 

   - File integrity monitoring
   - Fileless attack detection
   - Operating system patch assessment
   - Security misconfigurations assessment
   - Endpoint protection assessment

  ### Recommendations

- Install the Azure Security agent on Windows Arc machines to monitor them for security configurations and vulnerabilities. 

- Configure Arc machines to automatically create an association with the default data collection rule for Microsoft Defender for Cloud. 

- Enable Microsoft Defender for Cloud with Servers plan on the subscription for deploying and running Azure VMware Solution SDDC.

- For any guest VMs using Extended Security Benefits on Azure VMware Solution SDDC, deploy security updates regularly using the Volume Activation Management Tool. 

#### Assessment Question 
-  Have you done a threat analysis of your Azure VMware Solution workload?

### Intrusion Detection and Prevention Systems (IDPS): 

Deploying an IDPS solution will  detect and prevent network-based attacks and malicious activities within the AVS environment.


## Data Encryption
#### Impact: _Security_, _Infrastructure_

Data Encryption is an important aspect of keeping the Azure VMware Solution workload from unauthorized access and protecting the integrity of sensitive data. This includes both data at rest on the systems and data in transit. 
### Recommendations

- Encrypt vSAN storage with Customer Managed Keys to encrypt data at rest.
- Use native encryption tools such as BitLocker for encrypting guest VMs. 
- Use native database encryption options (e.g., TDE for SQL Server) for databases running on Azure VMware Solution SDDC guest VMs.
- Monitor database activities using native database monitoring tools (e.g., SQL Server Activity Monitor) for any suspicious activity monitoring.

#### Assessment Question
- Is data being encrypted both in transit and at rest? 

### Key Rotation 
It is significantly more challenging for attackers to access or misuse encrypted data without access to encryption keys. Keys, secrets, and certificates should be stored securely and frequently rotated.  A combination of encrypting the data, storing keys securely, and encrypting data at the application level before transmitting it are comprehensive steps to secure and maintain data integrity. 

### Recommendations
- Use Azure Key Vault to store encryption keys.

#### Asssement Question
Are there management and rotation mechanisms for keys, secrets, and certificates?

## Network Security:
#### Impact:  _Infrastructure_

Network security refers to preventing unauthorized access to different components of the Azure VMware Solution by implementing boundaries through network segmentation to create isolation between your applications. A VLAN operates at the data-link layer and provides physical separation of the virtual machines by partitioning the physical network into logical ones to separate traffic. 

Segments are then created to provide more advanced security capabilities and routing. For example, in a three-tier, the application, web, and database tier can have separate segments. From there, the application can have further micro-segmentation by adding security rules to restrict network communication between the VMs in each segment. 

![image](https://github.com/Azure/Enterprise-Scale-for-AVS/assets/6500757/35803331-1097-4772-a552-cc5c5dd97ff1)


In front of the segments sits the tier-1 routers, which provide routing capabilities within the SDDC. Multiple tier-1 routers can be deployed to segregate different sets of segments or to achieve specific routing.
For example, if you wanted to restrict traffic east/west from your prod and dev-test workloads, you can use distributed tier-1s to segment and filter the traffic based on specific rules and policies. 

<img width="646" alt="image" src="https://github.com/Azure/Enterprise-Scale-for-AVS/assets/6500757/e37e807f-a48b-4832-804c-be8530c6e757">

### Recommendations 
- Use network segments to logically separate and monitor different components
- Use NSX-T native microsegmentation capabilities to restrict network communication between different components in the application
- Use a centralized routing appliance to secue and optimize routing between segments
- Use staggered tier-1 routers when network segmention is driven by organizational security/networking policies, compliance requirements, business units, departments or environments. 

#### Assessment Question
- How is traffic between different components of the application transmitted securely?

### RBAC and Multi-Factor Authentication (MFA)
#### Impact:  _Security_, _Infrastructure_

Identity security controls access to Azure VMware Solution private cloud workloads and applications running on them to users, groups, and credentials. Using Role-Based Access Control (RBAC) assigns  roles and permissions appropriate to specific users and groups, which are then granted based on least privilege. 

Enforcing  MFA for user authentication  provides an additional layer of security against unauthorized access. Various MFA methods, such as mobile push notifications, offer a convenient user experience while ensuring strong authentication. Integrate AVS with Azure Active Directory (Azure AD) to centralize user management and leverage Azure AD's advanced security features such as PIM, MFA, and Conditional Acess. 
Data Protection:

### Recommendations

- Use Azure Active Directory Privileged Identity Management (PIM) to allow time-bound access to Azure Portal/Control pane operations. Use PIM Audit History to track operations performed by highly privileged accounts.  

- Reduce the number of Azure AD accounts that can access Azure Portal/APIs, navigate to Azure VMware Solution SDDC, and read vCenter and NSX-T admin accounts. 

- Rotate local `cloudadmin` accounts for vCenter and NSX-T to prevent misuse/abuse of these administrative accounts. Use these accounts only in “break glass” scenarios. Create vCenter server groups/users and assign them identities sourced from external identity sources. Use these groups/users for specific vCenter server and NSX-T data center operations. 

- Use a centralized identity source for configuring authentication and authorization services for guest VMs and applications.

#### Assessment question 

How are you managing identity for workloads running in Azure VMware Solution? 

## Security Monitoring and Threat Detection:
#### Impact: _Security_, _Operational Excellence_

This section refers to detecting and responding to changes in the security posture of Azure VMware Solution private cloud workloads. For specific use case, its important to follow industry best practices and comply with  regulatory requirements, such as GDPR, HIPAA, or PCI DSS.

Using a Security Information and Event Management (SIEM) tool or Azure Sentinel aggregates, monitors, and analyzes security logs and events to detect and respond to potential threats. Also maintaining a regular audit review will help monitor the AVS environment to ensure it aligns with security standards and policies.


### Recommendations 

- Automate responses to recommendations from Microsoft Defender for Cloud using the following Azure Policies: 

    - Workflow automation for security alerts 

    - Workflow automation for security recommendations 

    - Workflow automation for regulatory compliance changes 

- Deploy Microsoft Sentinel. When deploying Microsoft Sentinel, use the Log Analytics workspace that collects logs from Azure VMware Solution SDDC guest VMs. 

- Connect Microsoft Sentinel and Microsoft Defender for Cloud using a data connector. 

- Automate threat response using Microsoft Sentinel Playbooks and Automation rules. 

#### Assessment question 

- How are you monitoring security-related events in Azure VMware Solution? What tools do you use to monitor your Azure VMware Solution Private Cloud and clusters? 



It is important to note that securing AVS requires a shared responsibility model, where both Microsoft Azure and VMware are responsible for certain aspects of security. Ensure a clear understanding of the shared responsibility model and collaborate with both vendors to implement appropriate security measures.
