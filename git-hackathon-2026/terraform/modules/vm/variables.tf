variable "name" {
  description = "Nom de la VM"
  type        = string
}

variable "image_name" {
  description = "Nom de l'image OpenStack"
  type        = string
}

variable "flavor_name" {
  description = "Flavor (taille) de la VM"
  type        = string
}

variable "key_pair" {
  description = "Nom de la keypair SSH OpenStack"
  type        = string
}

variable "network_id" {
  description = "ID du réseau interne"
  type        = string
}

variable "security_groups" {
  description = "Liste des security groups à attacher"
  type        = list(string)
  default     = []
}

variable "floating_pool" {
  description = "Réseau externe pour l'IP flottante"
  type        = string
}

variable "user_data" {
  description = "Script cloud-init optionnel"
  type        = string
  default     = ""
}
