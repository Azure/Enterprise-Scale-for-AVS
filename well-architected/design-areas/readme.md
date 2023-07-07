# Design principles of an Azure VMware Solution workload

We built this guidance around the Azure Well-Architected Framework and its five pillars of architectural excellence. The table below lists each pillar and provides a general summary of the articles in this set.

| Well-architected framework pillar | Summary |
| --- | --- |
| Reliability |An Azure VMware Solution workload requires platform resiliency and high availability to protect critical business data. The Well-Architected framework assesses hybrid workloads running in the Azure VMware solution where the application footprint may extend to Azure Native Services. |
| Security| Secure the applications with multiple security layers, including identity and access management (IAM), input validation, data sovereignty, and encryption for DDOS mitigation, blocking bad actors, preventing data exfiltration, and providing protection from OS vulnerabilities. |
| Cost Optimization | A well-architected application deployment meets performance expectations while reducing the total cost of ownership.|
| Performance Efficiency | The application can optimize disk operations, has sufficient resources to scale with demand, and minimizes network latency for efficient communication between different components of a distributed workload. This includes load balancing, geographic placement, and caching mechanisms. |
| Operational Excellence | This pillar combines automation, monitoring, security measures, disaster recovery planning, performance optimization, and effective documentation to ensure smooth operations and maximize the value derived from VMware deployments.|

## Reliability

An optimal Azure VMware Solution workload exhibits both resilience and availability. Resilience refers to recovering from failures and maintaining functionality, while availability ensures uninterrupted uptime. High availability minimizes application downtime during critical maintenance and enhances recovery from incidents like VM crashes, backend updates, extended downtimes, or ransomware attacks. Since failures can occur on-premises and in the cloud, designing your AVS workload with a focus on resilience and availability is crucial.

**Conduct a reliability assessment.** Before you can standardize the reliability of an Azure VMware Solution workload, you need to assess its reliability. It’s critical to know how reliable an AVS workload is so steps can be taken to fix issues or solidify those configurations. One way to do this is by assessing your workload's reliability. The assessment asks  questions about a workload and provides specific recommendations to focus on. The assessment builds on itself, so you can track your progress constantly without restarting.

Start an [Azure Well-Architected Review](/assessments/azure-architecture-review/) for the assessment. Select "Start Assessment" and “Azure VMware Solution” when prompted.

## Security

In the shared responsibility model context, organizations are primarily responsible for managing and operating their workloads, while Microsoft manages the physical and virtual infrastructure of Azure VMware Solutions. It is strongly recommended to regularly assess the services and technologies used to ensure that your security posture adapts to the evolving threat landscape. Additionally, it is essential to establish a clear understanding of the shared responsibility model when collaborating with vendors to implement suitable security measures.

To secure the AVS environment, several methods can be employed. Network isolation through segments, VLANs, and network security groups (NSGs) for Azure Native services is recommended. Effective patch management, regular environmental audits, and security monitoring with a SIEM solution like Azure Sentinel are crucial. Encryption should be implemented for data at rest and in transit. Robust Identity and Access Management (IAM) practices should be in place, including the enforcement of multi-factor authentication (MFA), integration with Azure Active Directory, and the assignment of least privileged RBAC roles."

## Cost optimization

Microsoft and VMware make significant investments in the fast evolution of the hardware, the VMware hypervisor, and Azure native services to provide more value for less (e.g. suppressing egress charges out of the SDDC and including enterprise licensing of several services into the base costs). The frequent increase in Azure hardware capability provides a regular opportunity for an Azure VMware Solution workload to optimize costs, eliminate waste, and improve technology such as purchasing reservations. Consider creating a plan for each Azure VMware Solution application and its integration services. The plan should contain the objectives and motivations for the workload. Organizational objectives and investment priorities should drive cost optimization initiatives for your application, application platform, and data platform.

## Performance efficiency

This pillar focuses on a workload's ability to optimize and maximize workloads running on Azure dedicated hardware. This includes resource allocation and the ability to grow CPU, storage, memory, and network resources to meet application demands and tune these settings as needed. It's also important to continuously monitor performance and detect anomalies through tools such as VMware vRealize Operations Manager. Also, at the application layer, configuring specific settings to improve overall performance, such as query optimization at the data tier, in-memory caching of the application, and configuring HTTP headers and the web tier. Considering each of these aspects will allow for a well-architected application that delivers a consistent, cohesive user experience. 

## Operational excellence

Operational Excellence is leveraging the Azure VMware Solution's full capabilities while adhering to Well-architected best practices to secure, optimize, and scale workloads. This involves ensuring that there are processes in place for getting up-to-date patches and upgrades, maintaining governance and compliance, analyzing the performance and health of the environment, and comprehensive processes and documentation that captures troubleshooting procedures, disaster recovery plans, and remediation guidance on how to accelerate resolving problems. That way, teams can collaborate in a way that's efficient and transparent. 

## Next steps

These design principles are incorporated into our comprehensive guidance across specific design domains. Each design domain offers focused guidance, enabling you to quickly access the information you need for enhanced productivity within minimal time. Consider the headings as your navigational tool, guiding you toward the relevant direction for networking, core infrastructure, the application platform, monitoring, and operational procedures.

> [!div class="nextstepaction"]
> [Design principles](design-areas/application-platform.md)
