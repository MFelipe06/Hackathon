output "network_id" {
  description = "ID du réseau interne"
  value       = module.network.network_id
}

output "subnet_id" {
  description = "ID du subnet"
  value       = module.network.subnet_id
}

output "router_id" {
  description = "ID du router (gateway)"
  value       = module.network.router_id
}
