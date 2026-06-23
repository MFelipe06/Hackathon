variable "region" {
  description = "Infomaniak region"
  default     = "dc3-a"
}

variable "os_username" {
  description = "Infomaniak username"
  type        = string
}

variable "os_password" {
  description = "Infomaniak password"
  type        = string
  sensitive   = true
}

variable "os_project_name" {
  description = "Infomaniak project name"
  type        = string
}

variable "os_project_id" {
  description = "Infomaniak project ID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "course_type" {
  description = "Type de cours : linux-admin, dev-web, data-science, cybersecurity"
  type        = string
  default     = "linux-admin"
}

variable "vm_count" {
  description = "Nombre de VMs à provisionner"
  type        = number
  default     = 1
}

variable "student_name" {
  description = "Nom de l'étudiant ou du groupe"
  type        = string
  default     = "etudiant"
}

variable "end_date" {
  description = "Date de fin de la VM (YYYY-MM-DD)"
  type        = string
}
