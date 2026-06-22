# ─── Réseau interne ───────────────────────────────────────────────────────────
resource "openstack_networking_network_v2" "main" {
  name           = "${var.project_name}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "main" {
  name            = "${var.project_name}-subnet"
  network_id      = openstack_networking_network_v2.main.id
  cidr            = var.network_cidr
  ip_version      = 4
  dns_nameservers = ["84.16.67.69", "84.16.67.70"] # DNS Infomaniak
}

# ─── Router (gateway vers Internet) ───────────────────────────────────────────
resource "openstack_networking_router_v2" "main" {
  name                = "${var.project_name}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "main" {
  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.main.id
}

# ─── Réseau externe (référence) ───────────────────────────────────────────────
data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

# ─── Security Groups ──────────────────────────────────────────────────────────

# SG par défaut : trafic sortant autorisé
resource "openstack_networking_secgroup_v2" "default" {
  name        = "${var.project_name}-sg-default"
  description = "Trafic sortant autorisé, entrant bloqué par défaut"
}

resource "openstack_networking_secgroup_rule_v2" "egress_v4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.default.id
}

# SG SSH : accès port 22 depuis partout (à restreindre en prod)
resource "openstack_networking_secgroup_v2" "ssh" {
  name        = "${var.project_name}-sg-ssh"
  description = "Accès SSH (port 22)"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_ingress" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.ssh.id
}
