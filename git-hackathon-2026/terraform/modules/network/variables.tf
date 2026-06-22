variable "project_name" {
  type = string
}

variable "network_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "external_network" {
  type = string
}
