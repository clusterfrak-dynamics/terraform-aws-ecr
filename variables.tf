variable "env" {}

variable "registries" {
  type    = any
  default = []
}

variable "registries_policies" {
  type    = any
  default = []
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

variable "prefix_restriction" {
  default = ""
}

variable "aws" {
  type    = any
  default = {}
}
