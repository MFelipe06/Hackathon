# ─── Instance ─────────────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "vm" {
  name            = var.name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair
  security_groups = var.security_groups
  user_data       = var.user_data != "" ? var.user_data : null

  network {
    uuid = var.network_id
  }

  metadata = {
    provisioned_by = "terraform"
    project        = "git-hackathon"
  }
}

# ─── IP Flottante ─────────────────────────────────────────────────────────────
resource "openstack_networking_floatingip_v2" "vm" {
  pool = var.floating_pool
}

resource "openstack_compute_floatingip_associate_v2" "vm" {
  floating_ip = openstack_networking_floatingip_v2.vm.address
  instance_id = openstack_compute_instance_v2.vm.id
}
