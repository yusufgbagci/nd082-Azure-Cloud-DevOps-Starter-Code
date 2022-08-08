variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "Session"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
  default     = "eastus"
}

variable "vm_count" {
  description = "Number of Virtual Machines"
}


variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      environment = "environment"
   }
}

variable "admin_username" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "azureuser"
}