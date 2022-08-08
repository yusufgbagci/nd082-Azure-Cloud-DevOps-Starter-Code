# Udacity Project 1
## Overview of the project




The infrastructure to deploy it in a customizable way based on specifications provided at build time. It deploys it as pure IaaS cause of  control cost and also it deploys across multiple virtual machine.

-Main steps of this project:
- A Packer template
- A Terraform template
- Deploying the infrastructure


## Instructions for Running

Before we get started,you shuold deploy to policy that ensures all indexed resources are tagged. In this project you can find screenshot of deployed policy.

In order to support application deployment, I create a packer image "server.json" that different organizations can take advantage of to deploy their own apps

-To deploy Packer:
```sh
packer build server.json
```

Terraform template "main.tf" allows to reliably create, update, and destroy infrastructure. Built with variables and loops, along with our knowledge of Azure infrastructure, to deploy a web app that has been loaded into the Packer template already.

Terraform template requires to run variables file"var.tf" that has information about variables

-To deploy Terraform:
```sh
terraform init
```
```sh
terraform plan
```
```sh
terraform apply
```
And also for solution plan:
```sh
terraform apply -out solution.plan
```

## Description of how to customize the vars.tf for use
As I mentioned above the vars file contain variable for terraform template "main.tf"

- variable "prefix" = The prefix which used for all resources in this project #default_value = "Udacity"
- variable "location" = The Azure Region in which all resources in this project are created #default_value = "West Europe"
- variable "vm_count" = "Number of Virtual Machines"  #default_value = "2"
- variable "tags" = Map of the tags to use for the resources that are deployed #default_value = "enviroment"

```

## License

MIT

