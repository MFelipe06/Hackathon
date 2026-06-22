output "instance_id" {
  value = openstack_compute_instance_v2.vm.id
}

output "private_ip" {
  value = openstack_compute_instance_v2.vm.access_ip_v4
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.vm.address
}

output "name" {
  value = openstack_compute_instance_v2.vm.name
}
