# Azure VMware Solution Well-Architected Framework: Security


This section covers how to secure and protect workloads running in the. Azure VMware Solution (AVS) by implementing various measures to protect the infrastructure, data, and applications. This entails having a holistic approach that aligns with the organization's core priorities. 


## Infrastructure Security
#### Impact: _Security_, _Infrastructure_

This section refers to protecting underlying infrastructure components through regular updates, applying patches, and monitoring for security vulnerabilities or threats.

### Managing Compliance 
It's important to easily see and detect which servers are following out of compliance. Azure Arc is a service that allows you to extend Azure management and Azure services to on-premises or multi-cloud environments. By providing
centralized management and governance for servers, Azure ARC gives you a single pane glass view to applying updates and hotfixes in Azure, On-Premises, and AVS for a consistent management experience. 

### Recommendations 
- Configure Azure VMware Solution guest VMs as Azure Arc-enabled Servers by using one of the following method. 

- Azure Connected Machine agent deployment options 

- Deploy Arc for Azure VMware Solution (Preview) 

- Use Azure Policy for Azure Arc-enabled Servers to audit and enforce security controls on Azure VMware Solution guest VMs. Some of the key policies are as provided below. 

#### Assessment Questions 
- Have you done a threat analysis of your Azure VMware Solution workload? 

### Protecting the Guest OS
The operating system is susceptible to vulnerabilities if not patched and regularly updated, which can put your entire platform at risk. Patching regularly combined with an endpoint protection solution helps prevent 
common attack vectors that target the OS and keep your systems up to date. Azure Defender for Cloud has a unique set of tools that provide advanced threat protection across your Azure VMware Solution and on-premises virtual machines (VMs)
including 
* File integrity monitoring
* Fileless attack detection
* Operating system patch assessment
* Security misconfigurations assessment
* Endpoint protection assessment

  ### Recommendations

- Install the Azure Security agent on Windows Arc machines in order to monitor them for security configurations and vulnerabilities. 

- Configure Arc machines to automatically create an association with the default data collection rule for Microsoft Defender for Cloud. 

- System updates should be installed on your machines. 

- Enable Microsoft Defender for Cloud with Servers plan on the subscription that is used for deploying and running Azure VMware Solution SDDC.  

Network Security:

Network Isolation: Implement network segmentation and isolation using virtual LANs (VLANs) or virtual private clouds (VPCs) to prevent unauthorized access between different components of the AVS environment.
Network Security Groups: Configure network security groups (NSGs) to control inbound and outbound traffic, restricting access based on specific rules and policies.
Virtual Private Network (VPN): Establish encrypted VPN connections between on-premises networks and AVS to secure data in transit.
Identity and Access Management:

Role-Based Access Control (RBAC): Assign appropriate roles and permissions to users and groups within the AVS environment to ensure that access is granted on a least privilege basis.
Multi-Factor Authentication (MFA): Enforce MFA for user authentication to provide an additional layer of security against unauthorized access.
Azure Active Directory Integration: Integrate AVS with Azure Active Directory (Azure AD) to centralize user management and leverage Azure AD's advanced security features.
Data Protection:

Encryption: Encrypt sensitive data at rest using Azure Disk Encryption or other encryption mechanisms provided by the underlying storage infrastructure.
Backup and Disaster Recovery: Implement regular backups of VMs and critical data to ensure data availability and recoverability in the event of data loss or system failures. Leverage Azure Backup and Site Recovery services for comprehensive backup and disaster recovery capabilities.
Security Monitoring and Threat Detection:

Security Information and Event Management (SIEM): Utilize SIEM tools or Azure Sentinel to aggregate, monitor, and analyze security logs and events to detect and respond to potential threats.
Intrusion Detection and Prevention Systems (IDPS): Deploy IDPS solutions to detect and prevent network-based attacks and malicious activities within the AVS environment.
Vulnerability Scanning: Perform regular vulnerability scans and assessments to identify and remediate any security weaknesses or vulnerabilities.
Patch and Update Management:

Stay up to date with the latest security patches and updates for AVS components, including VMware software and underlying Azure infrastructure. Follow best practices for patch management to address known security vulnerabilities.
Compliance and Governance:

Follow industry best practices and comply with relevant regulatory requirements, such as GDPR, HIPAA, or PCI DSS, based on your specific use case.
Regularly audit and review the security posture of the AVS environment, ensuring that it aligns with security standards and policies.
It is important to note that securing AVS requires a shared responsibility model, where both Microsoft Azure and VMware are responsible for certain aspects of security. Ensure a clear understanding of the shared responsibility model and collaborate with both vendors to implement appropriate security measures.
