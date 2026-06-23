# 🖥️ GIT Hackathon 2026 — Plateforme Cloud

> Geneva Institute of Technology × Satom IT & Learning Solutions

Plateforme de provisioning de VMs en libre-service pour les étudiants et formateurs du GIT.

## Stack technique
- **Infra** : Terraform + Ansible sur Infomaniak Public Cloud (dc3-a)
- **Backend** : FastAPI (Python)
- **Frontend** : React
- **Auth** : OIDC / Entra ID (Office 365 GIT)
- **Monitoring** : Prometheus + Grafana
- **CI/CD** : GitHub Actions

## Déploiement rapide

```bash
# 1. Cloner le repo
git clone https://github.com/TON_ORG/git-hackathon-2026.git
cd git-hackathon-2026

# 2. Configurer les credentials Infomaniak
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
# Editer terraform.tfvars avec vos credentials

# 3. Déployer l'infra
cd infra/terraform
terraform init && terraform apply

# 4. Lancer le backend
cd ../../backend
docker-compose up -d
```

## Structure
- `infra/` — Terraform + Ansible (provisioning VMs)
- `backend/` — API FastAPI
- `frontend/` — Interface React
- `docs/` — Architecture, runbook, guides
