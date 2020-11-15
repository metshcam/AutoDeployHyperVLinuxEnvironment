# AutoDeployHyperVLinuxEnvironment

This project aims to leverage a lightweight host using nothing but an existing Windows 10 operating system, and the HyperV roled enabled and working.

The following are my goals:

1) Comprehensive guide on building a lightweight and readily available "parent" drive for CentOS8, using HyperV Gen2 virtual machines

2) Automate the process of creating your virtual network infrastructure, allowing you to choose how to deploy your linux environment under HyperV

3) Automate the entire configuration of an existing virtual machine

4) Build an automation stack that contains a self sustainable linux environment, using basic networking concepts and tools to replicate a deployment environment with the least amount of external tools

5) Learn how to customize and modulate the functions in order to allow the entire stack to be more manageable and scalable with future projects

6) Try and stay limited to the following technology:
  - Windows 10 operating system with VTd enabled, minimum
  - Enable OpenSSH client for Windows 10 (as a feature)
  - Only use SSH and native HyperV methods to communicate with, and configure deployments
