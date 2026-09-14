# QuickEat - MCD (Modèle Conceptuel de Données)

## 1. Les 4 Entités

| Entité | Rôle |
|--------|------|
| **UTILISATEUR** | Comptes étudiants et commerçants |
| **MENU** | Plats proposés par les commerçants |
| **COMMANDE** | Commandes passées par les étudiants |
| **DETAIL_COMMANDE** | Produits dans chaque commande |

---

## 2. Relations

```
UTILISATEUR ──||──o{ COMMANDE
```
- Un étudiant peut passer plusieurs commandes
- Une commande appartient à un seul étudiant

```
UTILISATEUR ──||──o{ MENU
```
- Un commerçant gère plusieurs menus
- Un menu appartient à un seul commerçant

```
COMMANDE ──||──|{ DETAIL_COMMANDE
```
- Une commande contient un ou plusieurs détails
- Un détail appartient à une seule commande

```
MENU ──||──o{ DETAIL_COMMANDE
```
- Un menu peut apparaître dans plusieurs commandes
- Un détail concerne un seul menu

---

## 3. Schéma Visuel

```
┌─────────────────┐                     ┌─────────────────┐
│   UTILISATEUR   │                     │      MENU       │
├─────────────────┤                     ├─────────────────┤
│ id_user      PK │                     │ id_menu      PK │
│ prenoms         │                     │ nom             │
│ nom             │                     │ description     │
│ email           │                     │ prix            │
│ telephone       │                     │ categorie       │
│ role            │                     │ disponibilite   │
│ photo_url       │                     │ id_commercant FK│
│ campus          │                     └────────┬────────┘
│ date_creation   │                              │ 1,n
└───────┬─────────┘                              │
        │ 1,n                                    │
        ▼                                        ▼
┌─────────────────┐                     ┌─────────────────┐
│     COMMANDE    │                     │ DETAIL_COMMANDE │
├─────────────────┤                     ├─────────────────┤
│ id_commande  PK │                     │ id_detail    PK │
│ id_etudiant  FK │                     │ id_commande  FK │
│ id_commercant FK│                     │ id_menu      FK │
│ date_commande   │                     │ quantite        │
│ montant_total   │                     │ prix_unitaire   │
│ type_reception  │                     └─────────────────┘
│ adresse_livraison│
│ statut          │
└─────────────────┘
```

---

## 4. Tables de Données

### UTILISATEUR
| Champ | Type | Description |
|-------|------|-------------|
| id_user | String (PK) | Identifiant unique |
| prenoms | String | Prénom(s), affiché sur la page profil |
| nom | String | Nom de famille |
| email | String | Email unique |
| telephone | String | Numéro de téléphone |
| mot_de_passe | String | Géré par Firebase Auth |
| role | String | STUDENT ou MERCHANT |
| photo_url | String | Photo de profil |
| campus | String | Campus d'inscription (étudiant ou commerçant) |
| date_creation | Date | Date d'inscription |

### MENU
| Champ | Type | Description |
|-------|------|-------------|
| id_menu | String (PK) | Identifiant unique |
| nom | String | Nom du plat |
| description | String | Description du plat |
| prix | Float | Prix en FCFA |
| image_url | String | Photo du plat |
| categorie | String | Catégorie du plat |
| disponibilite | Boolean | En stock ou non |
| id_commercant | String (FK) | Référence vers le commerçant |

### COMMANDE
| Champ | Type | Description |
|-------|------|-------------|
| id_commande | String (PK) | Identifiant unique |
| id_etudiant | String (FK) | Référence vers l'étudiant |
| id_commercant | String (FK) | Référence vers le commerçant |
| date_commande | Date | Date de la commande |
| montant_total | Float | Montant total en FCFA |
| type_reception | String | LIVRAISON ou RETRAIT |
| adresse_livraison | String | Adresse de livraison (si type_reception = LIVRAISON) |
| statut | String | Statut de la commande |

**Statuts possibles :**
- EN_ATTENTE
- ACCEPTEE
- EN_COURS_DE_LIVRAISON
- LIVREE
- TERMINEE
- RECU
- ANNULEE

**Règle d'annulation :**
Le statut `ANNULEE` est possible **uniquement** depuis `EN_ATTENTE`. Une fois la commande passée à `ACCEPTEE`, l'annulation n'est plus autorisée (la préparation est lancée) — la transition `ACCEPTEE → ANNULEE` n'existe pas.

**Workflow selon le type de réception :**

*Commandes en LIVRAISON (pas de `TERMINEE`)*
```
EN_ATTENTE → ACCEPTEE (commerçant) → EN_COURS_DE_LIVRAISON (commerçant) → LIVREE (étudiant)
```

*Commandes en RETRAIT (sur place)*
```
EN_ATTENTE → ACCEPTEE (commerçant) → TERMINEE (commerçant) → RECU (commerçant)
```

### DETAIL_COMMANDE
| Champ | Type | Description |
|-------|------|-------------|
| id_detail | String (PK) | Identifiant unique |
| id_commande | String (FK) | Référence vers la commande |
| id_menu | String (FK) | Référence vers le menu |
| quantite | Int | Nombre d'unités |
| prix_unitaire | Float | Prix unitaire en FCFA |

---

## 5. Schéma Firestore

```
users/{userId}
  ├── prenoms: "Moussa"
  ├── nom: "Ndiaye"
  ├── email: "moussa@gmail.com"
  ├── phone: "90000000"
  ├── role: "STUDENT"
  ├── campus: "Campus de Ngoa-Ekéllé"
  └── createdAt

merchants/{merchantId}  (optionnel)
  ├── nom_boutique: "Chez Tanti"
  ├── localisation: "Yaoundé"
  └── ownerId

menus/{menuId}
  ├── name: "Burger poulet"
  ├── price: 1500
  ├── category: "Fast Food"
  ├── imageUrl: "https://..."
  ├── available: true
  └── merchantId

orders/{orderId}
  ├── studentId
  ├── merchantId
  ├── totalAmount: 3000
  ├── deliveryType: "LIVRAISON"
  ├── deliveryAddress: "Résidence Campus Ngoa, ch. 12"
  ├── status: "EN_COURS_DE_LIVRAISON"
  └── createdAt

orders/{orderId}/items/{itemId}
  ├── menuId
  ├── name: "Burger poulet"
  ├── quantity: 2
  └── price: 1500
```

---

## 6. Gestion du Temps Réel

Pour le suivi en temps réel, Firestore écoute le champ `orders.status` :

**Vue étudiant (selon le type de réception)**

- Commande en `LIVRAISON` : `EN_ATTENTE` → `ACCEPTEE` → `EN_COURS_DE_LIVRAISON` → `LIVREE`
- Commande en `RETRAIT` : `EN_ATTENTE` → `ACCEPTEE` → `TERMINEE` → `RECU`

**Vue marchand (selon le type de réception)**

- Commande en `LIVRAISON` : `ACCEPTEE` → `EN_COURS_DE_LIVRAISON` → `LIVREE`
- Commande en `RETRAIT` : `ACCEPTEE` → `TERMINEE` → `RECU`

`LIVREE` est confirmée par l'étudiant qui reçoit sa commande ; `RECU` est confirmé par le commerçant lors de la remise sur place. L'étudiant reçoit directement la mise à jour quand le commerçant change le statut.

---

**Lien du diagramme :** https://www.figma.com/board/xBTz5mNCcZtNMq6SpSExCj
