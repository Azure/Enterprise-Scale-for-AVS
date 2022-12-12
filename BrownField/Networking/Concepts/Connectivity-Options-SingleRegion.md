---
title:  Outbound Connectivity Options - Single Region
author: Sabine Blair
ms.author: sablair
ms.date: 12/8/2022
ms.topic: conceptual
ms.service: cloud-adoption-framework
ms.subservice: ready
ms.custom: internal
---

# Introduction

AVS has many options for connectivity such as AVS native services like Managed SNAT and Public IP as well as Azure native services such as Azure VWAN Hub and Azure Firewall. Traversing back to on-prem is also an option. Without a one-size fits all solution, how do you know which architecture is best for your environment?

This blog will talk about the different tools and servies available to have internet flows from AVS. In addition to that, we'll also discuss how to "level up" your architecture using ALZ concept to build a more secure, resilient, scalable design. 

##Default Route from On-Premises
Lets first look at a basic setup. In AVS, you create a segment(s) and under that segment, you have some VM's that you want to install some packages on from the internet. 

Your segments are attached to the default tier 1 which as a direct path out to the tier-0. 
![image.png](/.attachments/image-43d61353-20e4-47ba-ba44-62021c3b4db7.png)
The problem is, you haven't configured your default route, 0.0.0.0/0 (aka quad-0).

The AVS Portal shows that you have 3 options. Use the two native options, or something else. 
![internet_ops.png](/.attachments/internet_ops-18a25c41-2272-4b71-b0e0-940aef336e5f.png)