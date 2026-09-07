
# QuickEat — Campus Meal Delivery & Pickup
[![CI Workflow](https://github.com/DavFilsDev/quick-eat-app/actions/workflows/ci.yml/badge.svg)](https://github.com/DavFilsDev/quick-eat-app/actions/workflows/ci.yml)
![Flutter Version](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)

**QuickEat** est une application mobile d'e-commerce et de services locaux dédiée aux étudiants d'un campus universitaire. Elle permet de commander des repas en choisissant entre la livraison sur campus ou le retrait sur place, tout en offrant aux commerçants une interface de suivi et de gestion des statuts de commande en temps réel.

---

## 🎯 Fonctionnalités Principales

### 🎓 Côté Étudiant (`Login as Student`)
- **Parcours Repas :** Consultation du catalogue des restaurants et des menus du campus.
- **Gestion du Panier :** Ajout/suppression d'articles, modification des quantités et calcul dynamique du total.
- **Validation de Commande :** Choix du mode de réception (Livraison sur campus ou Retrait immédiat).
- **Suivi Temps Réel :** Visualisation de l'évolution du statut de la commande (`En attente` ➔ `En préparation` ➔ `Prête` ➔ `Livrée`).

### 🏪 Côté Commerçant (`Login as Merchant`)
- **Dashboard Commerçant :** Réception et affichage centralisé des commandes entrantes.
- **Gestion des Statuts :** Mise à jour en temps réel de l'état d'avancement de chaque commande.

---

## 🛠️ Stack Technique

- **Frontend :** [Flutter](https://flutter.dev) (v3.47.2) / Dart (v3.13.2)
- **Backend & Database :** Firebase (Firebase Auth, Cloud Firestore)
- **Architecture :** Feature-First (Clean Architecture simplifiée)
- **CI/CD :** GitHub Actions (Formatage, Analyse Statique, Tests Unitaires)

---

## 📂 Architecture du Projet

Le projet suit une structure **Feature-First** pour permettre un développement modulaire et indépendant au sein de l'équipe :

```text
lib/
├── main.dart             # Point d'entrée de l'application
├── app.dart              # Configuration globale MaterialApp & Thème
├── routes/               # Gestion du routage de l'application
├── core/                 # Thème, couleurs, constantes & widgets réutilisables
├── models/               # Modèles de données Dart (UserModel, OrderModel, etc.)
└── features/             # Modules fonctionnels
    ├── auth/             # Connexion & Choix de rôle
    ├── home/             # Écran d'accueil & Catalogue
    ├── cart/             # Panier & State Management
    ├── checkout/         # Validation de la commande
    └── order_tracking/   # Suivi de commande temps réel

```

---

## 🚀 Installation & Lancement Local

### Prérequis

* Flutter SDK (v3.47.2)
* Git

### Étapes

1. **Cloner le dépôt :**
```bash
git clone https://github.com/DavFilsDev/quick-eat-app.git
cd quickeat
```


2. **Installer les dépendances :**
```bash
flutter pub get
```


3. **Lancer l'application :**
```bash
flutter run
```



---

## 🧪 Contrôle Qualité Local (CI/CD)

Avant d'ouvrir une Pull Request, exécuter les vérifications requises par la CI :

```bash
# 1. Formatage du code
dart format .

# 2. Analyse statique
flutter analyze

# 3. Execution des tests
flutter test
```

---