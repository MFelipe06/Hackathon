# ✅ Guide Utilisateur — Validateur
## Plateforme Cloud GIT — Geneva Institute of Technology

---

## Bienvenue !

Ce guide explique comment gérer les demandes de VMs, approuver ou refuser les requêtes, et surveiller le parc de machines.

---

## 1. Se connecter au portail

1. Va sur **https://git-cloud.satom.ch**
2. Clique sur **"Se connecter avec Office 365"**
3. Entre tes identifiants GIT (compte avec rôle validateur)
4. Tu arrives sur le **tableau de bord validateur**

---

## 2. Gérer les demandes en attente

### Voir les demandes

Dans le tableau de bord, tu vois toutes les demandes en attente :

| Colonne | Description |
|:---|:---|
| **Demandeur** | Étudiant ou formateur |
| **Cours** | Type de VM demandé |
| **Nb VMs** | Nombre de machines |
| **Date début** | Quand la VM est nécessaire |
| **Date fin** | Destruction automatique prévue |
| **Statut** | En attente / Approuvée / Refusée |

---

### Approuver une demande

1. Clique sur la demande
2. Vérifie les informations :
   - Le cours existe bien au GIT ?
   - La date de fin est raisonnable ?
   - Le nombre de VMs est cohérent ?
3. Clique sur **"Approuver"**
4. Le provisioning démarre automatiquement
5. Le demandeur reçoit un email de confirmation

---

### Refuser une demande

1. Clique sur la demande
2. Clique sur **"Refuser"**
3. Indique un **motif de refus** (obligatoire)
4. Le demandeur reçoit un email avec le motif

**Motifs de refus courants :**
- Date de fin manquante ou trop lointaine
- Nombre de VMs excessif par rapport au groupe
- Template non adapté au cours demandé
- Budget du projet insuffisant

---

## 3. Surveiller le parc de VMs

### Tableau de bord coûts

| Indicateur | Description |
|:---|:---|
| **VMs actives** | Nombre de machines en fonctionnement |
| **Coût heure** | Coût total du parc à l'instant T |
| **Coût mois estimé** | Projection sur le mois |
| **VMs expirées aujourd'hui** | Machines détruites par le scheduler |

### État des machines

```
✅ Active    — VM en fonctionnement, accessible
⏳ En cours  — Provisioning en cours (~5-10 min)
❌ Erreur    — Provisioning échoué, intervention nécessaire
🗑️ Détruite  — VM supprimée (date de fin atteinte)
```

---

## 4. Actions d'urgence

### Détruire une VM immédiatement

Si une VM doit être détruite avant sa date de fin (usage inapproprié, sécurité) :

1. Va dans **"Parc de VMs"**
2. Sélectionne la VM
3. Clique sur **"Détruire maintenant"**
4. Confirme l'action
5. Le demandeur est notifié par email

### Depuis la ligne de commande (admin)

```bash
# Détruire une VM spécifique
openstack server delete NOM_VM --os-cloud infomaniak

# Supprimer la keypair associée
openstack keypair delete keypair-NOM_VM
```

---

### Prolonger une VM

Si un formateur demande une prolongation :

1. Va dans **"Demandes de prolongation"**
2. Vérifie le motif et la nouvelle date de fin
3. Approuve ou refuse
4. Si approuvé : mettre à jour le metadata `end_date` via l'API

```bash
# Via OpenStack CLI
openstack server set \
  --property end_date=2026-08-01 \
  NOM_VM
```

---

## 5. Rapports et monitoring

### VMs qui expirent bientôt

```bash
# Lancer le scheduler en mode dry-run pour voir les VMs à risque
python3 infra/scheduler/scheduler.py
```

Le scheduler affiche :
```
⚠️  VM git-linux-admin-dupont-marie-1 expire dans 1 jour(s) !
VM active : git-dev-web-martin-jean-1 (5 jour(s) restant(s))
```

### Coûts par cours

| Template | Coût/h | Coût/jour (8h) |
|:---|:---:|:---:|
| linux-admin | ~CHF 0.004 | ~CHF 0.032 |
| dev-web | ~CHF 0.008 | ~CHF 0.064 |
| data-science | ~CHF 0.008 | ~CHF 0.064 |
| cybersecurity | ~CHF 0.008 | ~CHF 0.064 |

### Lister toutes les VMs actives

```bash
openstack server list --os-cloud infomaniak
```

---

## 6. Bonnes pratiques

- ✅ **Traiter les demandes dans les 24h** — les formateurs planifient leurs cours
- ✅ **Toujours exiger une date de fin** — refuser les demandes sans date de fin
- ✅ **Vérifier le budget** avant d'approuver des demandes groupées importantes
- ✅ **Notifier les formateurs** 24h avant la destruction des VMs de leur cours
- ❌ **Ne pas approuver des dates de fin supérieures à 3 mois** sans justification
- ❌ **Ne pas laisser des VMs en erreur** sans intervention

---

## 7. Contacts et escalade

| Situation | Contact |
|:---|:---|
| VM bloquée en provisioning > 15 min | Équipe DevOps |
| Dépassement de budget Infomaniak | Responsable projet |
| Faille de sécurité suspectée | Admin système immédiatement |
| Demande de nouveau template | Équipe DevOps |

---

> 📌 **Support technique** : Canal Teams `#git-cloud-support`  
> 🔐 **Incident sécurité** : Canal Teams `#git-cloud-security`  
> 🏫 **Geneva Institute of Technology** × Satom IT & Learning Solutions
