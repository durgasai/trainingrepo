variable "customerrgnameprefix" {
  default       = "rg"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "customerrglocation" {
  default = "eastus"
  description   = "Location of the resource group."
}