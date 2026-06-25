# 🏗️ Document d'Architecture — GIT Hackathon 2026
## Plateforme Cloud de Provisioning de VMs
### Geneva Institute of Technology × Satom IT & Learning Solutions

> **Format** : ADR (Architecture Decision Records)  
> **Date** : Juin 2026  
> **Statut** : ✅ Validé — Revue d'architecture semaine 1

---

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    PLATEFORME GIT CLOUD                         │
│                                                                 │
│  Étudiant/Formateur                                             │
│       │                                                         │
│       ▼                                                         │
│  [Portail React] ──► [API FastAPI] ──► [Terraform + Ansible]   │
│                           │                      │              │
│                           ▼                      ▼              │
│                     [PostgreSQL]      [Infomaniak dc3-a]        │
│                                              │                  │
│                      [Scheduler] ────────────┘                  │
│                    (destruction auto)                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## ADR-001 — Choix du provider cloud : Infomaniak

**Contexte**  
Le projet nécessite un hébergement cloud pour les VMs étudiantes. Plusieurs options ont été évaluées : AWS, Azure, GCP, Infomaniak.

**Décision**  
Nous avons choisi **Infomaniak Public Cloud (dc3-a, Genève)**.

**Justification**
- Imposé par le cahier des charges (compte fourni par le GIT)
- Hébergement en Suisse — conformité RGPD et données étudiantes
- Compatible OpenStack — standard ouvert, pas de vendor lock-in
- Tarification à l'usage — adapté à des VMs éphémères

**Alternatives rejetées**
- AWS/Azure/GCP : coûts plus élevés, données hors Suisse, pas fournis

---

## ADR-002 — Choix de l'IaC : Terraform

**Contexte**  
Le provisioning des VMs doit être automatisé et reproductible.

**Décision**  
Nous avons choisi **Terraform** avec le provider OpenStack.

**Justification**
- Standard de l'industrie pour l'IaC
- Provider OpenStack natif compatible Infomaniak
- Modules réutilisables (vm, network) — facilite l'ajout de templates
- State Terraform — évite les ressources orphelines
- Metadata sur les VMs — permet au scheduler de lire end_date

**Structure des modules**
```
terraform/
├── modules/vm/       # VM générique paramétrée par course_type
└── modules/network/  # Security group par cours
```

**Alternatives rejetées**
- Ansible seul : moins adapté à la gestion d'état d'infrastructure
- OpenTofu : compatible mais Terraform plus mature et documenté

---

## ADR-003 — Choix de la configuration : Ansible

**Contexte**  
Chaque VM doit être configurée avec les outils spécifiques au cours demandé.

**Décision**  
Nous avons choisi **Ansible** avec une architecture en rôles.

**Justification**
- Agentless — pas besoin d'installer un agent sur les VMs
- SSH natif — cohérent avec notre modèle de sécurité
- Rôles réutilisables — un rôle `common` + un rôle par cours
- Idempotent — safe à relancer en cas d'échec

**Architecture des rôles**
```
roles/
├── common/        # Base : paquets, SSH hardening, dossier cours
├── linux-admin/   # nmap, ufw, fail2ban, nginx
├── dev-web/       # Node.js 20, Docker, Docker Compose
├── data-science/  # Python3, pandas, JupyterLab, scikit-learn
└── cybersecurity/ # nmap, wireshark, hydra, trivy
```

**Alternatives rejetées**
- cloud-init seul : moins flexible pour des configurations complexes
- Chef/Puppet : courbe d'apprentissage plus élevée, agent requis

---

## ADR-004 — Choix du backend : FastAPI

**Contexte**  
Une API est nécessaire pour orchestrer le provisioning et gérer les demandes.

**Décision**  
Nous avons choisi **FastAPI (Python)**.

**Justification**
- Async natif — adapté aux tâches longues (terraform apply ~2min)
- Background tasks — provisioning non bloquant
- OpenAPI/Swagger auto-généré — documentation API gratuite
- Python — même langage que openstacksdk et Ansible

**Endpoints principaux**
```
POST /vms/provision     # Demande de provisioning
GET  /vms/status/{id}   # Statut du provisioning
GET  /vms/templates     # Liste des templates disponibles
```

**Alternatives rejetées**
- Flask : pas d'async natif
- Node.js/Express : écosystème différent du reste de l'infra Python

---

## ADR-005 — Destruction automatique : Scheduler Python

**Contexte**  
Toute VM doit être détruite automatiquement à sa date de fin pour éviter les coûts inutiles.

**Décision**  
Nous avons choisi un **scheduler Python** avec **openstacksdk** lancé par cron.

**Justification**
- Lit le metadata `end_date` directement depuis l'API OpenStack
- Aucune base de données nécessaire — source de vérité = Infomaniak
- Simple et fiable — pas de dépendance externe
- Exécution horaire via cron — délai max 1h après expiration

**Fonctionnement**
```
Cron (toutes les heures)
    │
    ▼
scheduler.py
    ├── Liste VMs avec managed_by=git-hackathon-terraform
    ├── Compare end_date avec date du jour
    ├── Avertit si expiration dans 24h
    └── Détruit VM + keypair si expirée
```

**Alternatives rejetées**
- terraform destroy : nécessite le state local — pas adapté à un scheduler
- Cron OpenStack natif : non disponible sur Infomaniak

---

## ADR-006 — Sécurité : SSH uniquement + Security Groups

**Contexte**  
Les VMs doivent être accessibles de manière sécurisée par les étudiants.

**Décision**  
Authentification **SSH par clé ed25519** uniquement, avec **security group par cours**.

**Justification**
- Pas de mot de passe root partagé — chaque VM a sa propre keypair
- Clé ed25519 — plus sécurisée que RSA, clé plus courte
- Security group par cours — isolation réseau de base entre classes
- `PasswordAuthentication no` via Ansible — hardening automatique

**Modèle de sécurité**
```
Internet
    │
    ▼ Port 22 (SSH uniquement)
Security Group sg-{course_type}
    │
    ▼
VM ubuntu (clé ed25519 unique)
    │
    └── PasswordAuthentication: no
```

**Alternatives rejetées**
- VPN : complexité supplémentaire pour les étudiants
- Bastion host : surcoût et complexité pour un prototype

---

## ADR-007 — Flavors par template de cours

**Contexte**  
Les besoins en ressources varient selon le cours.

**Décision**  
Mapping fixe `course_type → flavor` dans le module Terraform.

| Template | Flavor | CPU | RAM | Disque | Justification |
|:---|:---|:---:|:---:|:---:|:---|
| linux-admin | a1-ram2-disk20-perf1 | 1 | 2 Go | 20 Go | Outils légers |
| dev-web | a1-ram4-disk50-perf1 | 1 | 4 Go | 50 Go | Docker + Node |
| data-science | a1-ram4-disk50-perf1 | 1 | 4 Go | 50 Go | Python + Jupyter |
| cybersecurity | a1-ram4-disk50-perf1 | 1 | 4 Go | 50 Go | Outils sécurité |

> Note : Le flavor `a1-ram8-disk50-perf1` n'existe pas sur Infomaniak dc3-a — data-science utilise donc 4 Go RAM.

---

## Flux complet de provisioning

```
1. Étudiant soumet demande (course_type, end_date, ssh_public_key)
         │
         ▼
2. Validateur approuve → API FastAPI reçoit la demande
         │
         ▼
3. terraform apply
   ├── Security group sg-{course_type} créé
   ├── Keypair unique créée
   └── VM créée avec metadata (course_type, end_date, managed_by)
         │
         ▼
4. Attente SSH disponible (~60-90 secondes)
         │
         ▼
5. ansible-playbook {course_type}.yml
   ├── role common : paquets base + SSH hardening
   └── role {course_type} : outils du cours
         │
         ▼
6. VM prête → notification étudiant (IP + instructions)
         │
         ▼
7. [À end_date] scheduler.py détruit VM + keypair
```

---

## Contraintes et limites connues

| Contrainte | Impact | Mitigation |
|:---|:---|:---|
| Quota security group rules (max 9/groupe) | Limite le nombre de règles par SG | Un SG par cours, règles minimales |
| Quota keypairs Infomaniak | Erreur 403 si trop de keypairs | Nettoyage via scheduler |
| Timeout destroy security group (~10min) | terraform destroy lent | Suppression manuelle via openstack CLI |
| Flavor RAM 8Go absent | data-science limité à 4Go | Flavor a1-ram4 utilisé |
| Provisioning Ansible ~5-10min | Latence de mise à disposition | Background task FastAPI + polling status |

---

> 📌 **Document** : ADR Architecture — GIT Hackathon 2026  
> 🏫 **Client** : Geneva Institute of Technology  
> 📅 **Date** : Juin 2026  
> ✅ **Revue d'architecture** : Semaine 1 validée
