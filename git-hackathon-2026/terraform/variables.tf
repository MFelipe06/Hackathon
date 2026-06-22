# ─── Projet ───────────────────────────────────────────────────────────────────
variable "project_name" {
  description = "Nom du projet (préfixe pour toutes les ressources)"
  type        = string
  default     = "git-hackathon"
}

variable "region" {
  description = "Région Infomaniak OpenStack"
  type        = string
  default     = "dc3-a"
}

# ─── Réseau ───────────────────────────────────────────────────────────────────
variable "network_cidr" {
  description = "CIDR du réseau interne"
  type        = string
  default     = "10.10.0.0/24"
}

variable "external_network" {
  description = "Nom du réseau externe Infomaniak (floating IPs)"
  type        = string
  default     = "ext-floating1"
}

# ─── VM ───────────────────────────────────────────────────────────────────────
variable "vm_image" {
  description = "Image de base pour les VMs (Ubuntu 22.04)"
  type        = string
  default     = "Ubuntu 22.04 LTS Jammy Jellyfish"
}

variable "vm_flavor" {
  description = "Flavor par défaut (taille) des VMs"
  type        = string
  default     = "a1-ram2-disk20-perf1"
}

variable "ssh_public_key" {
  description = "Clé SSH publique pour accès aux VMs"
  type        = string
  sensitive   = true
}

variable "ssh_key_name" {
  description = "Nom de la keypair OpenStack"
  type        = string
  default     = "git-hackathon-key"
}
