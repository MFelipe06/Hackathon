# Flavors par type de cours
locals {
  flavors = {
    linux-admin   = "a1-ram2-disk20-perf1"
    dev-web       = "a1-ram4-disk50-perf1"
    data-science  = "a1-ram8-disk50-perf1"
    cybersecurity = "a1-ram4-disk50-perf1"
  }
  flavor = local.flavors[var.course_type]
}

resource "openstack_compute_keypair_v2" "vm_keypair" {
  name       = "keypair-${var.vm_name}"
  public_key = var.ssh_public_key
}

resource "openstack_compute_instance_v2" "vm" {
  name            = var.vm_name
  flavor_name     = local.flavor
  image_id        = "1cb0a6a2-2dc2-46cd-bb23-1070d7f0e9d6"  # Ubuntu 22.04
  key_pair        = openstack_compute_keypair_v2.vm_keypair.name
  security_groups = [var.security_group_name]

  network {
    name = "ext-net1"
  }

  metadata = {
    course_type  = var.course_type
    student      = var.student_name
    end_date     = var.end_date
    managed_by   = "git-hackathon-terraform"
  }
}
