# ─── Keypair SSH ──────────────────────────────────────────────────────────────
resource "openstack_compute_keypair_v2" "main" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key
}

# ─── Module Réseau ────────────────────────────────────────────────────────────
module "network" {
  source = "./modules/network"

  project_name     = var.project_name
  network_cidr     = var.network_cidr
  external_network = var.external_network
}

# ─── Exemple : 1 VM de test (Linux Admin) ────────────────────────────────────
# Décommente pour créer une VM de test
# module "vm_test" {
#   source = "./modules/vm"
#
#   name            = "${var.project_name}-linux-admin-01"
#   image_name      = var.vm_image
#   flavor_name     = var.vm_flavor
#   key_pair        = openstack_compute_keypair_v2.main.name
#   network_id      = module.network.network_id
#   security_groups = [module.network.sg_ssh_name, module.network.sg_default_name]
#   floating_pool   = var.external_network
# }
