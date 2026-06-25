# 🖥️ GIT Hackathon 2026 — Plateforme Cloud de Provisioning de VMs

> Geneva Institute of Technology × Satom IT & Learning Solutions  
> Hackathon Juin 2026

## 📋 Description

Plateforme de provisioning de machines virtuelles en libre-service pour les étudiants et formateurs du Geneva Institute of Technology (GIT).

Un étudiant se connecte, demande une VM pour son cours, un validateur approuve, la VM est provisionnée automatiquement avec tous les outils du cours — et détruite automatiquement à la date de fin.

---

## 🏗️ Architecture

```
Étudiant/Formateur → Portail Web (React)
                          │
                          ▼
                    API FastAPI
                          │
                          ├──► Terraform → VM Infomaniak
                          ├──► Ansible   → Outils du cours
                          └──► Scheduler → Destruction auto
```

**Stack technique :**
- **Infra** : Terraform + Ansible sur Infomaniak Public Cloud (dc3-a)
- **Backend** : FastAPI (Python)
- **Frontend** : React
- **Auth** : OIDC / Entra ID (Office 365 GIT)
- **Scheduler** : Python + openstacksdk
- **CI/CD** : GitHub Actions

---

## 🚀 Déploiement rapide (de zéro)

### Prérequis

```bash
# Outils requis
terraform --version    # >= 1.5
ansible --version      # >= 2.14
python3 --version      # >= 3.10
pip3 install openstacksdk --break-system-packages
```

### 1. Cloner le repo

```bash
git clone https://github.com/TON_ORG/git-hackathon-2026.git
cd git-hackathon-2026
```

### 2. Configurer les credentials Infomaniak

```bash
mkdir -p ~/.config/openstack
cat > ~/.config/openstack/clouds.yaml << 'YAML'
clouds:
  infomaniak:
    auth:
      auth_url: https://api.pub1.infomaniak.cloud/identity
      username: "PCU-XXXXXXXX"
      password: "TON_MOT_DE_PASSE"
      project_id: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      project_name: "PCP-XXXXXXXX"
      user_domain_name: "Default"
    region_name: "dc3-a"
    interface: "public"
    identity_api_version: 3
YAML
```

### 3. Générer une clé SSH

```bash
ssh-keygen -t ed25519 -C "git-hackathon" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub  # Copier pour terraform.tfvars
```

### 4. Configurer Terraform

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Contenu de `terraform.tfvars` :
```hcl
os_username     = "PCU-XXXXXXXX"
os_password     = "TON_MOT_DE_PASSE"
os_project_name = "PCP-XXXXXXXX"
os_project_id   = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
ssh_public_key  = "ssh-ed25519 AAAA..."
course_type     = "linux-admin"   # linux-admin | dev-web | data-science | cybersecurity
vm_count        = 1
student_name    = "nom-etudiant"
end_date        = "2026-07-01"    # Format YYYY-MM-DD
```

### 5. Provisionner une VM

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -auto-approve
```

**Output attendu :**
```
Apply complete! Resources: 6 added.

Outputs:
vm_ips   = ["X.X.X.X"]
vm_names = ["git-linux-admin-nom-etudiant-1"]
```

### 6. Installer les outils du cours via Ansible

```bash
cd infra/ansible

ansible-playbook \
  -i inventory/hosts.yml \
  playbooks/linux-admin.yml \
  --extra-vars "vm_ip=X.X.X.X" \
  --private-key ~/.ssh/id_ed25519 \
  -u ubuntu
```

### 7. Se connecter à la VM

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X
cat ~/cours/README.txt
```

### 8. Destruction manuelle

```bash
cd infra/terraform
terraform destroy -auto-approve
```

### 9. Destruction automatique (scheduler)

```bash
# Lancer manuellement
python3 infra/scheduler/scheduler.py

# Configurer le cron (toutes les heures)
crontab -e
# Ajouter :
# 0 * * * * /usr/bin/python3 /chemin/vers/git-hackathon-2026/infra/scheduler/scheduler.py
```

---

## 📚 Templates de cours disponibles

| Template | Flavor | RAM | Outils installés |
|:---|:---|:---:|:---|
| `linux-admin` | a1-ram2-disk20-perf1 | 2 Go | nmap, ufw, fail2ban, nginx |
| `dev-web` | a1-ram4-disk50-perf1 | 4 Go | Node.js 20, Docker, Docker Compose, nginx |
| `data-science` | a1-ram4-disk50-perf1 | 4 Go | Python3, pandas, numpy, scikit-learn, JupyterLab |
| `cybersecurity` | a1-ram4-disk50-perf1 | 4 Go | nmap, wireshark, hydra, john, sqlmap, nikto, trivy |

---

## 📁 Structure du repo

```
git-hackathon-2026/
├── README.md                        # Ce fichier
├── docs/
│   ├── architecture.md              # Décisions ADR
│   ├── runbook.md                   # Exploitation
│   └── guides/
│       ├── etudiant.md
│       ├── formateur.md
│       └── validateur.md
├── infra/
│   ├── terraform/                   # IaC — création VMs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── terraform.tfvars.example
│   │   └── modules/
│   │       ├── vm/
│   │       └── network/
│   ├── ansible/                     # Configuration VMs
│   │   ├── ansible.cfg
│   │   ├── inventory/
│   │   ├── playbooks/
│   │   └── roles/
│   │       ├── common/
│   │       ├── linux-admin/
│   │       ├── dev-web/
│   │       ├── data-science/
│   │       └── cybersecurity/
│   └── scheduler/                   # Destruction automatique
│       ├── scheduler.py
│       └── requirements.txt
├── backend/                         # API FastAPI
│   ├── app/
│   ├── Dockerfile
│   └── requirements.txt
└── frontend/                        # Interface React
```

---

## 🔐 Sécurité

- **SSH uniquement** — pas de mot de passe root partagé
- **Clé SSH par VM** — keypair unique générée par Terraform
- **Security group par cours** — isolation réseau de base entre classes
- **Secrets** — jamais committés (`terraform.tfvars` dans `.gitignore`)
- **SSH hardening** — `PasswordAuthentication no` via Ansible role common

---

## 💰 Gestion des coûts

| Flavor | CPU | RAM | Disque | Prix/h estimé |
|:---|:---:|:---:|:---:|:---:|
| a1-ram2-disk20-perf1 | 1 | 2 Go | 20 Go | ~CHF 0.004 |
| a1-ram4-disk50-perf1 | 1 | 4 Go | 50 Go | ~CHF 0.008 |

> ⚠️ Toute VM doit avoir une `end_date` — le scheduler détruit automatiquement les VMs expirées toutes les heures.

---

## 🔄 Cycle de vie d'une VM

```
Demande étudiant
      │
      ▼
Validation (validateur)
      │
      ▼
terraform apply → VM créée sur Infomaniak
      │
      ▼
ansible-playbook → Outils du cours installés
      │
      ▼
VM accessible via SSH (clé ed25519)
      │
      ▼
scheduler.py (cron horaire) → VM détruite à end_date
```

---

## 👥 Équipe

| Rôle | Membre |
|:---|:---|
| Provisioning Cloud (Terraform + Ansible + Scheduler) | Felipe Daniel Mamani |
| Backend API (FastAPI) | À compléter |
| Frontend (React) | À compléter |
| Auth (OIDC/Entra ID) | À compléter |

---

## 🗓️ Jalons

| Date | Jalon | Status |
|:---|:---|:---:|
| 11 juin 2026 | Lancement + constitution équipe | ✅ |
| 19 juin 2026 | Revue d'architecture | ✅ |
| 26 juin 2026 | Démo live + remise livrables | 🟡 |

---

> 📌 **Infrastructure** : Infomaniak Public Cloud · dc3-a · Genève 🇨🇭  
> 🐍 **IaC** : Terraform v1.54 + Ansible  
> 📅 **Hackathon** : Juin 2026  
> 🏫 **Client** : Geneva Institute of Technology
