variable "vm_name" {
  description = "Nom de la VM"
  type        = string
}

variable "course_type" {
  description = "Type de cours"
  type        = string
}

variable "ssh_public_key" {
  description = "Clé SSH publique"
  type        = string
}

variable "security_group_name" {
  description = "Nom du security group"
  type        = string
}

variable "end_date" {
  description = "Date de fin de la VM"
  type        = string
}

variable "student_name" {
  description = "Nom de l'étudiant"
  type        = string
}
