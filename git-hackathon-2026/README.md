# GIT Hackathon 2026 — Plateforme de provisioning de VMs

Plateforme de provisioning automatisé de machines virtuelles pour le Geneva Institute of Technology.
Infrastructure sur **Infomaniak Public Cloud (OpenStack, région dc3-a)**.

## Stack technique

| Couche | Outil |
|---|---|
| Infrastructure as Code | Terraform |
| Configuration | Ansible |
| Conteneurs | Docker |
| CI/CD | GitHub Actions |
| Cloud | Infomaniak OpenStack (dc3-a) |

## Prérequis

- Terraform >= 1.5
- Python >= 3.10 + `ansible` + `openstacksdk`
- Un fichier `~/.config/openstack/clouds.yaml` valide (Infomaniak)

## Démarrage rapide

```bash
# 1. Cloner le repo
git clone https://github.com/<org>/git-hackathon-2026.git
cd git-hackathon-2026

# 2. Copier et remplir les variables Terraform
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Éditer terraform.tfvars avec ta clé SSH publique

# 3. Initialiser et appliquer
cd terraform
terraform init
terraform plan
terraform apply
```

## Structure du repo

```
.
├── .github/workflows/   # CI/CD GitHub Actions
├── terraform/           # Infrastructure as Code
│   ├── modules/
│   │   ├── network/     # VPC, subnet, security groups
│   │   └── vm/          # Instance + floating IP
├── ansible/             # Playbooks de configuration
│   ├── inventory/
│   └── playbooks/
└── docs/                # Architecture & runbooks
```

## Variables importantes

Copier `terraform/terraform.tfvars.example` → `terraform/terraform.tfvars` et renseigner :

| Variable | Description |
|---|---|
| `ssh_public_key` | Contenu de ta clé publique SSH |
| `vm_image` | Nom exact de l'image dans OpenStack |
| `vm_flavor` | Flavor (taille) de la VM |

> ⚠️ Ne jamais committer `terraform.tfvars`, `clouds.yaml` ou toute clé privée.

## Équipe

- Felipe (Nuke) — Infrastructure / IaC
