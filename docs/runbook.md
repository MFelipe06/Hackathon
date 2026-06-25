# 📖 Runbook d'exploitation — GIT Hackathon 2026
## Plateforme Cloud de Provisioning de VMs
### Geneva Institute of Technology × Satom IT & Learning Solutions

> **Usage** : Ce document décrit les procédures d'exploitation courantes et la résolution des incidents.  
> **Audience** : Administrateurs système, équipe DevOps

---

## 🚀 Opérations courantes

### Provisionner une VM manuellement

```bash
cd infra/terraform

# Éditer les paramètres
nano terraform.tfvars
# course_type  = "linux-admin" | "dev-web" | "data-science" | "cybersecurity"
# student_name = "nom-etudiant"
# vm_count     = 1
# end_date     = "2026-07-01"

terraform apply -auto-approve
```

### Installer les outils du cours via Ansible

```bash
cd infra/ansible

ansible-playbook \
  -i inventory/hosts.yml \
  playbooks/{course_type}.yml \
  --extra-vars "vm_ip=X.X.X.X" \
  --private-key ~/.ssh/id_ed25519 \
  -u ubuntu
```

### Lister toutes les VMs actives

```bash
openstack server list --os-cloud infomaniak
```

### Vérifier l'état d'une VM spécifique

```bash
openstack server show NOM_OU_ID_VM
```

### Lancer le scheduler manuellement

```bash
python3 infra/scheduler/scheduler.py
```

### Détruire une VM manuellement

```bash
# Via Terraform (recommandé)
cd infra/terraform
terraform destroy -auto-approve

# Via OpenStack CLI (si Terraform state perdu)
openstack server delete NOM_VM
openstack keypair delete keypair-NOM_VM
openstack security group delete sg-{course_type}
```

---

## 🔥 Résolution d'incidents

### ❌ Une VM ne se provisionne pas

**Symptôme** : `terraform apply` échoue

**Arbre de décision :**

```
terraform apply échoue
        │
        ├── Erreur 403 "Quota exceeded keypairs"
        │       └── Solution : openstack keypair list
        │                      openstack keypair delete NOM_CLE
        │
        ├── Erreur 409 "Security group in use"
        │       └── Solution : openstack server list (trouver VM qui utilise le SG)
        │                      openstack server delete NOM_VM
        │                      sleep 10
        │                      openstack security group delete NOM_SG
        │
        ├── Erreur "Unable to find flavor"
        │       └── Solution : openstack flavor list | grep ram
        │                      Mettre à jour modules/vm/main.tf avec flavor disponible
        │
        ├── Erreur "Timeout security group destroy"
        │       └── Solution : terraform state rm module.network...
        │                      openstack security group delete NOM_SG (manuellement)
        │
        └── Erreur authentification
                └── Solution : vérifier ~/.config/openstack/clouds.yaml
                               vérifier OS_PASSWORD
```

---

### ❌ Ansible échoue après la création de la VM

**Symptôme** : `ansible-playbook` retourne `unreachable` ou `failed`

**Vérifications :**

```bash
# 1. La VM est-elle accessible ?
ping X.X.X.X

# 2. Le port SSH est-il ouvert ?
nc -zv X.X.X.X 22

# 3. La clé SSH est-elle correcte ?
ssh -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X

# 4. Si "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED"
ssh-keygen -f ~/.ssh/known_hosts -R X.X.X.X
```

**Si la VM vient d'être créée :**
```bash
# Attendre 60-90 secondes que cloud-init termine
sleep 90
ansible-playbook ...
```

---

### ❌ Le scheduler ne détruit pas une VM expirée

**Symptôme** : VM expirée toujours active après l'heure

**Vérifications :**

```bash
# 1. Vérifier les metadata de la VM
openstack server show NOM_VM | grep metadata

# 2. La VM a-t-elle bien managed_by=git-hackathon-terraform ?
# Si non → destruction manuelle nécessaire

# 3. Lancer le scheduler manuellement
python3 infra/scheduler/scheduler.py

# 4. Vérifier les logs
cat /var/log/git-scheduler.log

# 5. Vérifier le cron
crontab -l
```

**Destruction manuelle d'urgence :**
```bash
openstack server delete NOM_VM
openstack keypair delete keypair-NOM_VM
```

---

### ❌ Quota de security group rules dépassé

**Symptôme** : `Error 409 OverQuota security_group_rule`

**Solution :**
```bash
# Lister les security groups
openstack security group list

# Supprimer les anciens SG inutilisés
openstack security group delete NOM_SG

# Ou supprimer une règle spécifique via la console Infomaniak
# Console → Network → Security Groups → Delete Rule
```

---

### ❌ State Terraform désynchronisé

**Symptôme** : `terraform apply` dit que des ressources existent déjà

**Solution :**
```bash
# Voir ce qui est dans le state
terraform state list

# Supprimer une ressource du state (sans la détruire sur Infomaniak)
terraform state rm RESSOURCE

# Importer une ressource existante dans le state
terraform import RESSOURCE ID_OPENSTACK

# Forcer un refresh du state
terraform refresh
```

---

### ❌ API FastAPI ne répond pas

**Symptôme** : `curl http://IP:8000/health` timeout

**Vérifications :**
```bash
# 1. Le conteneur tourne-t-il ?
docker ps | grep backend

# 2. Voir les logs
docker logs git-backend

# 3. Relancer
docker-compose restart backend

# 4. Le port 8000 est-il ouvert dans le security group ?
openstack security group show NOM_SG | grep 8000
```

---

## 📋 Procédures de maintenance

### Ajouter un nouveau template de cours

**Étape 1 — Terraform (flavor)**

Éditer `infra/terraform/modules/vm/main.tf` :
```hcl
locals {
  flavors = {
    linux-admin   = "a1-ram2-disk20-perf1"
    dev-web       = "a1-ram4-disk50-perf1"
    data-science  = "a1-ram4-disk50-perf1"
    cybersecurity = "a1-ram4-disk50-perf1"
    NOUVEAU_COURS = "a1-ram4-disk50-perf1"  # ← ajouter ici
  }
}
```

**Étape 2 — Ansible (role)**
```bash
mkdir -p infra/ansible/roles/NOUVEAU_COURS/tasks
cat > infra/ansible/roles/NOUVEAU_COURS/tasks/main.yml << 'EOF'
---
- name: Installation outils NOUVEAU_COURS
  apt:
    name:
      - outil1
      - outil2
    state: present
  become: yes
EOF
```

**Étape 3 — Playbook**
```bash
cat > infra/ansible/playbooks/NOUVEAU_COURS.yml << 'EOF'
---
- name: Provisioning VM NOUVEAU_COURS
  hosts: all
  gather_facts: yes
  roles:
    - common
    - NOUVEAU_COURS
EOF
```

**Étape 4 — Tester**
```bash
# Modifier terraform.tfvars
course_type = "NOUVEAU_COURS"

terraform apply -auto-approve
ansible-playbook playbooks/NOUVEAU_COURS.yml --extra-vars "vm_ip=X.X.X.X"
```

---

### Gérer une demande bloquée

**Symptôme** : Demande en statut `provisioning` depuis plus de 15 minutes

```bash
# 1. Vérifier l'état de la VM sur Infomaniak
openstack server list | grep NOM_VM

# 2. Si VM existe mais Ansible n'a pas tourné → relancer Ansible manuellement
ansible-playbook playbooks/{course_type}.yml --extra-vars "vm_ip=X.X.X.X"

# 3. Si VM n'existe pas → relancer terraform apply
terraform apply -auto-approve

# 4. Mettre à jour le statut dans l'API
# PUT /vms/status/{job_id} {"status": "failed", "message": "Relance manuelle nécessaire"}
```

---

### Nettoyage des ressources orphelines

```bash
# Lister toutes les VMs du projet
openstack server list

# Lister toutes les keypairs
openstack keypair list

# Supprimer les keypairs orphelines (sans VM associée)
openstack keypair delete keypair-NOM_VM

# Lister les security groups inutilisés
openstack security group list
openstack security group delete NOM_SG
```

---

## 📊 Monitoring

### Vérifier l'état du parc de VMs

```bash
# Toutes les VMs actives
openstack server list --os-cloud infomaniak

# VMs par metadata
openstack server list --long | grep git-hackathon

# Ressources consommées (depuis la VM)
ssh -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X "top -bn1 | head -20"
```

### Vérifier les logs du scheduler

```bash
cat /var/log/git-scheduler.log | tail -50
```

---

## 🔐 Gestion des secrets

```bash
# Ne JAMAIS committer
terraform.tfvars          # Credentials Infomaniak
~/.config/openstack/clouds.yaml  # Credentials OpenStack
*.tfstate                 # State Terraform (contient des secrets)

# Toujours vérifier avant un push
git status
cat .gitignore
```

---

> 📌 **Document** : Runbook d'exploitation — GIT Hackathon 2026  
> 🏫 **Client** : Geneva Institute of Technology  
> 📅 **Date** : Juin 2026
