# Flavors par type de cours
locals {
  flavors = {
    linux-admin   = "a1-ram2-disk20-perf1"
    dev-web       = "a1-ram4-disk50-perf1"
    data-science  = "a1-ram4-disk50-perf1"
    cybersecurity = "a1-ram4-disk50-perf1"
  }

  flavor = local.flavors[var.course_type]
}

# 🔍 Récupération dynamique de l'image Ubuntu
data "openstack_images_image_v2" "ubuntu" {
  name        = "Ubuntu 22.04 LTS Jammy Jellyfish"
  most_recent = true
  visibility  = "public"
}

# 🔑 Keypair SSH
resource "openstack_compute_keypair_v2" "vm_keypair" {
  name       = "keypair-${var.vm_name}"
  public_key = var.ssh_public_key
}

# 🖥️ VM
resource "openstack_compute_instance_v2" "vm" {
  name        = var.vm_name
  flavor_name = local.flavor

  # ✅ Utilisation dynamique de l’image
  image_id = data.openstack_images_image_v2.ubuntu.id

  key_pair        = openstack_compute_keypair_v2.vm_keypair.name
  security_groups = [var.security_group_name]

  network {
    name = "ext-net1"
  }

  metadata = {
    course_type = var.course_type
    student     = var.student_name
    end_date    = var.end_date
    managed_by  = "git-hackathon-terraform"
  }
}
