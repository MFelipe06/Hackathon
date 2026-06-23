output "vm_ips" {
  value = module.vm[*].vm_ip
}

output "vm_names" {
  value = module.vm[*].vm_name
}
