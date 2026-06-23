module "network" {
  source      = "./modules/network"
  course_type = var.course_type
}

module "vm" {
  count       = var.vm_count
  source      = "./modules/vm"

  vm_name             = "git-${var.course_type}-${var.student_name}-${count.index + 1}"
  course_type         = var.course_type
  ssh_public_key      = var.ssh_public_key
  security_group_name = module.network.security_group_name
  end_date            = var.end_date
  student_name        = var.student_name
}
