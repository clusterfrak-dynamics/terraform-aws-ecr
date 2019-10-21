variable "env" {}

variable "aws" {
  type    = any
  default = {}
}

variable "registries" {
  type    = any
  default = {}
}

variable "custom_tags" {
  type    = map
  default = {}
}

variable "project" {
  default = ""
}

variable "prefix" {
  default = ""
}
