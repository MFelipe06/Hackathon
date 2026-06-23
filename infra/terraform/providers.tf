terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.54"
    }
  }
}

provider "openstack" {
  auth_url            = "https://api.pub1.infomaniak.cloud/identity/v3"
  region              = var.region
  user_domain_name    = "default"
  project_domain_name = "default"
}
