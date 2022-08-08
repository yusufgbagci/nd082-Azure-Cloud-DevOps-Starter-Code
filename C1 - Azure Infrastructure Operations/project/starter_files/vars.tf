variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "Udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  type        = string
  default     = "West Europe"
}

variable "vm_count" {
  description = "Number of Virtual Machines"
  default     = "2"
}


variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type= map(string)
      default = {
      environment = "environment"
   }
}
