output "network_id" {
  value = openstack_networking_network_v2.main.id
}

output "subnet_id" {
  value = openstack_networking_subnet_v2.main.id
}

output "router_id" {
  value = openstack_networking_router_v2.main.id
}

output "sg_default_name" {
  value = openstack_networking_secgroup_v2.default.name
}

output "sg_ssh_name" {
  value = openstack_networking_secgroup_v2.ssh.name
}
