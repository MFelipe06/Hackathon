# 🎓 Guide Utilisateur — Étudiant
## Plateforme Cloud GIT — Geneva Institute of Technology

---

## Bienvenue !

Ce guide explique comment demander et utiliser une machine virtuelle (VM) pour ton cours.

---

## 1. Se connecter au portail

1. Va sur **https://git-cloud.satom.ch** (ou l'URL fournie par ton formateur)
2. Clique sur **"Se connecter avec Office 365"**
3. Entre tes identifiants GIT (même que Teams/Outlook)
4. Tu arrives sur le tableau de bord étudiant

---

## 2. Demander une VM

1. Clique sur **"Nouvelle demande"**
2. Remplis le formulaire :

| Champ | Description | Exemple |
|:---|:---|:---|
| **Cours** | Sélectionne ton cours dans la liste | Administration Linux |
| **Date de début** | Quand tu as besoin de la VM | 2026-06-26 |
| **Date de fin** | Quand tu n'en auras plus besoin | 2026-07-10 |
| **Clé SSH publique** | Ta clé pour te connecter à la VM | `ssh-ed25519 AAAA...` |

3. Clique sur **"Envoyer la demande"**
4. Tu reçois un email de confirmation

> ⚠️ **Important** : La date de fin est obligatoire. La VM sera détruite automatiquement à cette date.

---

## 3. Générer ta clé SSH (si tu n'en as pas)

**Sur Windows (PowerShell) :**
```powershell
ssh-keygen -t ed25519 -C "ton.email@git.ch"
# Appuyer sur Entrée pour accepter le chemin par défaut
# Afficher la clé publique :
type $env:USERPROFILE\.ssh\id_ed25519.pub
```

**Sur Linux/Mac/WSL :**
```bash
ssh-keygen -t ed25519 -C "ton.email@git.ch"
cat ~/.ssh/id_ed25519.pub
```

Copie la ligne complète qui commence par `ssh-ed25519 AAAA...` et colle-la dans le formulaire.

---

## 4. Attendre la validation

- Ton formateur ou le validateur reçoit ta demande
- Tu recevras un email **"Demande approuvée"** ou **"Demande refusée"**
- Si approuvée : la VM est prête en **5 à 10 minutes**

---

## 5. Se connecter à ta VM

Quand tu reçois l'email de confirmation, il contient l'**adresse IP** de ta VM.

**Sur Windows (PowerShell) :**
```powershell
ssh -i $env:USERPROFILE\.ssh\id_ed25519 ubuntu@X.X.X.X
```

**Sur Linux/Mac/WSL :**
```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X
```

Tu verras le message de bienvenue de ton cours :
```
=====================================
Cours : Administration Linux
Geneva Institute of Technology
=====================================
Outils installés : nmap, ufw, fail2ban, nginx, lvm2
```

---

## 6. Outils disponibles par cours

### 🐧 Administration Linux
- `nmap` — scanner réseau
- `ufw` — pare-feu
- `fail2ban` — protection brute-force
- `nginx` — serveur web
- `lvm2` — gestion volumes logiques

### 🌐 Développement Web
- `node` — Node.js 20
- `npm` — gestionnaire de paquets
- `docker` — conteneurs
- `docker-compose` — orchestration
- `nginx` — serveur web

### 📊 Data Science
- `python3` — Python 3.10
- `pandas`, `numpy`, `matplotlib` — analyse de données
- `scikit-learn` — machine learning
- `jupyterlab` — notebooks interactifs

**Lancer Jupyter :**
```bash
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
# Puis ouvrir http://X.X.X.X:8888 dans ton navigateur
```

### 🔐 Cybersécurité / CTF
- `nmap` — scanner réseau
- `wireshark` — analyse réseau
- `hydra` — test de mots de passe
- `john` — cracker de hash
- `sqlmap` — test injection SQL
- `nikto` — scanner web
- `trivy` — scan de vulnérabilités

---

## 7. Bonnes pratiques

- ✅ **Sauvegarder ton travail** — la VM sera détruite à la date de fin
- ✅ **Ne pas partager ta clé SSH privée** avec personne
- ✅ **Demander une prolongation** si tu as besoin de plus de temps
- ❌ **Ne pas installer des outils non liés au cours** — cela augmente les coûts
- ❌ **Ne pas laisser des processus inutiles** tourner en arrière-plan

---

## 8. Problèmes fréquents

| Problème | Solution |
|:---|:---|
| "Connection refused" | Attendre 5 min, la VM démarre encore |
| "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED" | `ssh-keygen -R X.X.X.X` |
| "Permission denied (publickey)" | Vérifier que tu utilises la bonne clé SSH |
| VM inaccessible | Contacter ton formateur |

---

## 9. Fin du cours

Ta VM sera **automatiquement détruite** à la date de fin que tu as indiquée.

> ⚠️ **Sauvegarde ton travail avant la date de fin !**  
> Exporte tes fichiers avec `scp` :
> ```bash
> scp -i ~/.ssh/id_ed25519 ubuntu@X.X.X.X:/home/ubuntu/cours/* ./mon-travail/
> ```

---

> 📌 **Support** : Contacte ton formateur ou écris sur le canal Teams du cours  
> 🏫 **Geneva Institute of Technology** × Satom IT & Learning Solutions
