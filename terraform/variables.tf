variable "project" {
  type    = string
  default = "zipdeploy"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "dev"
}

variable "tags" {
  type = map(string)
  default = {
    owner = "maintainer@organization.com"
  }
}
