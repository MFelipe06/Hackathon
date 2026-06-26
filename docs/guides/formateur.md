# 👨‍🏫 Guide Utilisateur — Formateur
## Plateforme Cloud GIT — Geneva Institute of Technology

---

## Bienvenue !

Ce guide explique comment préparer un cours, demander des VMs pour tes étudiants et gérer ton parc de machines.

---

## 1. Se connecter au portail

1. Va sur **https://git-cloud.satom.ch**
2. Clique sur **"Se connecter avec Office 365"**
3. Entre tes identifiants GIT
4. Tu arrives sur le **tableau de bord formateur**

---

## 2. Préparer un cours — Demande groupée de VMs

### Demande pour N étudiants

1. Clique sur **"Nouveau cours"**
2. Remplis le formulaire :

| Champ | Description | Exemple |
|:---|:---|:---|
| **Nom du cours** | Intitulé du module | Administration Linux — Groupe E1 |
| **Template** | Type de VM | linux-admin |
| **Nombre de VMs** | Un par étudiant | 20 |
| **Date de début** | Premier jour du cours | 2026-09-01 |
| **Date de fin** | Dernier jour du cours | 2026-09-30 |

3. Clique sur **"Envoyer la demande groupée"**
4. Le validateur reçoit la demande pour approbation

> 💡 **Conseil** : Soumets la demande **48h avant le début du cours** pour laisser le temps à la validation et au provisioning.

---

## 3. Templates de cours disponibles

| Template | Cours associé | Outils principaux | Ressources |
|:---|:---|:---|:---|
| `linux-admin` | Administration Linux | nmap, ufw, fail2ban, nginx | 2 Go RAM |
| `dev-web` | Développement Web | Node.js 20, Docker, nginx | 4 Go RAM |
| `data-science` | Data Science | Python3, pandas, JupyterLab | 4 Go RAM |
| `cybersecurity` | Cybersécurité / CTF | nmap, wireshark, hydra, trivy | 4 Go RAM |

> 📩 Pour demander un nouveau template, contacte l'équipe DevOps avec la liste des outils nécessaires.

---

## 4. Distribuer les accès aux étudiants

Quand les VMs sont provisionnées, tu reçois un email avec :
- La liste des IPs (une par étudiant)
- Les instructions de connexion SSH

**Exemple de communication aux étudiants :**
```
Bonjour,

Votre VM pour le cours Administration Linux est prête.
IP de votre machine : X.X.X.X
Connexion : ssh -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X

Les outils du cours sont déjà installés.
Bonne pratique !
```

---

## 5. Gérer ton parc de VMs

### Voir l'état de tes VMs

Dans le tableau de bord formateur :
- **Vert** : VM active et accessible
- **Orange** : VM en cours de provisioning
- **Rouge** : VM inaccessible ou erreur
- **Gris** : VM détruite

### Coûts estimés

| Template | Coût/VM/heure | Coût/VM/mois (8h/jour) |
|:---|:---:|:---:|
| linux-admin | ~CHF 0.004 | ~CHF 0.64 |
| dev-web | ~CHF 0.008 | ~CHF 1.28 |
| data-science | ~CHF 0.008 | ~CHF 1.28 |
| cybersecurity | ~CHF 0.008 | ~CHF 1.28 |

> 💰 **Important** : Les VMs sont facturées à l'usage. Une bonne date de fin = économies garanties.

---

## 6. Prolonger ou modifier un cours

Si le cours dure plus longtemps que prévu :

1. Va dans **"Mes cours actifs"**
2. Clique sur **"Demander une prolongation"**
3. Indique la nouvelle date de fin
4. Le validateur reçoit la demande

> ⚠️ La demande doit être faite **avant** la date de fin actuelle, sinon les VMs seront déjà détruites.

---

## 7. Bonnes pratiques

- ✅ **Indiquer une date de fin précise** — évite les coûts inutiles
- ✅ **Vérifier que les étudiants ont leurs clés SSH** avant le début du cours
- ✅ **Tester la VM** sur le template avant le cours
- ✅ **Prévenir les étudiants 24h avant la destruction** de leurs VMs
- ❌ **Ne pas demander plus de VMs que d'étudiants inscrits**

---

## 8. Ajouter un nouveau template

Si tu as besoin d'un template non disponible :

1. Contacte l'équipe DevOps avec :
   - Nom du cours
   - Liste des outils à installer
   - Ressources nécessaires (RAM, disque)
2. L'équipe crée le role Ansible et teste le template
3. Le template est disponible dans les 48h

---

> 📌 **Support** : Canal Teams `#git-cloud-support`  
> 🏫 **Geneva Institute of Technology** × Satom IT & Learning Solutions
