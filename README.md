# QuickEat — Commande de repas sur campus

[![CI Workflow](https://github.com/DavFilsDev/quick-eat-app/actions/workflows/ci.yml/badge.svg)](https://github.com/DavFilsDev/quick-eat-app/actions/workflows/ci.yml)
![Flutter Version](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/License-MIT-green)

QuickEat est une application mobile Flutter permettant aux étudiants d'un campus
universitaire de commander des repas auprès des commerçants présents sur le
campus, en choisissant la livraison ou le retrait sur place, et de suivre
l'avancement de leur commande en temps réel. Les commerçants disposent quant à
eux d'un tableau de bord pour traiter les commandes entrantes et gérer leur menu.

Le backend repose sur Firebase (Firebase Authentication et Cloud Firestore). Le
projet est développé en architecture Feature-First, avec une séparation nette
entre l'accès aux données, les modèles et l'interface.

---

## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Architecture](#architecture)
- [Modèle de données](#modèle-de-données)
- [Stack technique](#stack-technique)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration des environnements](#configuration-des-environnements)
- [Lancement](#lancement)
- [Qualité et intégration continue](#qualité-et-intégration-continue)
- [Tests](#tests)
- [Structure du projet](#structure-du-projet)
- [Documentation](#documentation)
- [Limitations connues et évolutions](#limitations-connues-et-évolutions)
- [Licence](#licence)

---

## Fonctionnalités

### Authentification et gestion des rôles

- Inscription et connexion via Firebase Authentication (email et mot de passe).
- Détection automatique du rôle (`RoleDetector`) à partir du domaine de l'email
  (domaines universitaires pour les étudiants, domaines publics neutres, autres
  domaines assimilés aux commerçants), complétée par un choix explicite du rôle
  lors de l'inscription.
- Inscription assistée : sélecteur d'indicatif téléphonique parmi 54 pays
  africains (recherche par nom ou par code) et choix du campus avec l'option
  « Autre » permettant de saisir un campus personnalisé.
- Redirection automatique après connexion vers l'espace correspondant au rôle
  (`AuthGate`).
- Édition du profil, réinitialisation du mot de passe par email et déconnexion.

### Espace étudiant

- Catalogue des restaurants et de leurs plats, avec recherche texte et filtres
  par catégorie, restaurant et campus.
- Fiche restaurant listant les plats disponibles d'un commerçant.
- Passage de commande depuis un plat : choix du mode de réception (livraison sur
  campus ou retrait) et de la quantité, avec calcul dynamique du montant total.
- Suivi des commandes en temps réel, annulation possible tant que la commande
  est au statut `En attente` et confirmation de réception pour les retraits.

### Espace commerçant

- Navigation par onglets : **Accueil**, **Menus** et **Profil**.
- Tableau de bord des commandes entrantes en temps réel, avec compteur des
  commandes en cours et détail de chaque commande.
- Mise à jour du statut des commandes selon le type de réception.
- Écran de gestion complète du menu (`MerchantMenuScreen`) accessible depuis
  l'onglet **Menus** : création, modification et suppression d'un plat, et
  activation ou désactivation de sa disponibilité.
- Recherche textuelle par nom, filtre par catégories (y compris la catégorie
  personnalisée « Autre ») et tri par prix croissant ou décroissant.
- Profil du commerçant incluant les informations du stand.

### Notifications in-app

- Cloche de notification (`NotificationBell`) intégrée à l'AppBar commune
  (`QuickEatAppBar`), avec badge dynamique du nombre de notifications non lues.
- Historique complet accessible depuis la cloche (`NotificationScreen`), avec
  distinction visuelle des notifications lues et non lues et horodatage relatif.
- Notifications générées automatiquement : nouvelle commande côté commerçant,
  et commande prête (retrait) ou en cours de livraison côté étudiant.
- À l'ouverture d'une notification, redirection vers l'onglet **Commandes** de
  l'espace concerné ; la notification est alors marquée comme lue.
- Préférence d'activation ou de désactivation persistée dans le profil
  (`users/{uid}.notificationsActivees`).
- L'AppBar affiche désormais la cloche à la place de l'avatar et du menu de
  déconnexion ; la déconnexion reste accessible depuis le profil.

### Cycle de vie des commandes

| Statut | Libellé | Origine |
|--------|---------|---------|
| `EN_ATTENTE` | En attente | Statut initial à la création |
| `ACCEPTEE` | Acceptée | Validation par le commerçant |
| `EN_COURS_DE_LIVRAISON` | En cours de livraison | Commande en livraison |
| `LIVREE` | Livrée | Fin de livraison |
| `TERMINEE` | Terminée | Commande à retrait prête |
| `RECU` | Reçue | Réception confirmée par l'étudiant |
| `ANNULEE` | Annulée | Annulation par l'étudiant avant acceptation |

Transitions selon le mode de réception :

- Livraison : `ACCEPTEE` puis `EN_COURS_DE_LIVRAISON` puis `LIVREE`.
- Retrait : `ACCEPTEE` puis `TERMINEE` puis `RECU`.
- Annulation (`ANNULEE`) autorisée uniquement depuis `EN_ATTENTE`.

---

## Architecture

Le projet suit une architecture Feature-First avec une clean architecture
simplifiée :

- `core` : éléments transverses (thème, couleurs, styles, erreurs, widgets
  réutilisables, garde d'authentification).
- `data/repositories` : contrats d'accès aux données et implémentations
  Firestore, injectables pour les tests.
- `models` : modèles de données Dart et énumérations métier.
- `features` : modules fonctionnels autonomes (auth, catalog,
  menu_management, orders, profile, shell), chacun organisé en
  `presentation/{controllers,screens,widgets}` et, si nécessaire, `domain`.
- `routes` : déclaration centralisée des routes de l'application.
- `services` : services transverses, dont l'initialisation des données de
  démonstration Firestore.

La gestion d'état s'appuie sur `provider` et des `ChangeNotifier` (contrôleurs)
exposés aux vues. Les contrôleurs dépendent des interfaces de repositories, ce
qui permet de les tester avec des implémentations simulées (`mocktail`).

---

## Modèle de données

Le détail complet des entités et relations est disponible dans
[`docs/mcd.md`](docs/mcd.md).

### Collection `users`

Document `users/{userId}` :

| Champ | Type | Description |
|-------|------|-------------|
| `idUser` | string | Identifiant de l'utilisateur (UID Firebase) |
| `prenoms` | string | Prénoms |
| `nom` | string | Nom |
| `email` | string | Adresse email |
| `telephone` | string | Numéro de téléphone |
| `role` | string | `STUDENT` ou `MERCHANT` |
| `photoUrl` | string | URL de la photo de profil |
| `campus` | string | Campus de rattachement (prédéfini ou personnalisé) |
| `notificationsActivees` | boolean | Préférence de réception des notifications in-app (défaut : `true`) |
| `dateCreation` | timestamp | Date de création du compte |

### Collection `menus`

Document `menus/{menuId}` :

| Champ | Type | Description |
|-------|------|-------------|
| `idFood` | string | Identifiant du plat (égal à l'identifiant du document) |
| `nom` | string | Nom du plat |
| `description` | string | Description |
| `prix` | number | Prix en FCFA |
| `imageUrl` | string | URL de l'image |
| `categorie` | string | Catégorie du plat |
| `disponible` | boolean | Disponibilité du plat |
| `idCommercant` | string | Référence au commerçant propriétaire |

### Collection `orders` et sous-collection `items`

Document `orders/{orderId}` :

| Champ | Type | Description |
|-------|------|-------------|
| `idCommande` | string | Identifiant de la commande |
| `idEtudiant` | string | Référence à l'étudiant |
| `idCommercant` | string | Référence au commerçant |
| `dateCommande` | timestamp | Date de la commande |
| `montantTotal` | number | Montant total en FCFA |
| `typeReception` | string | `LIVRAISON` ou `RETRAIT` |
| `adresseLivraison` | string | Adresse de livraison (si livraison) |
| `statut` | string | Statut courant de la commande |

Document `orders/{orderId}/items/{itemId}` :

| Champ | Type | Description |
|-------|------|-------------|
| `idFood` | string | Référence au plat commandé |
| `nom` | string | Nom du plat au moment de la commande |
| `quantite` | number | Quantité commandée |
| `prixUnitaire` | number | Prix unitaire en FCFA |

### Sous-collection `users/{uid}/notifications`

Document `users/{uid}/notifications/{idNotification}` :

| Champ | Type | Description |
|-------|------|-------------|
| `idNotification` | string | Identifiant de la notification |
| `idUtilisateur` | string | Référence à l'utilisateur destinataire |
| `titre` | string | Titre de la notification |
| `message` | string | Contenu du message |
| `idCommande` | string | Référence optionnelle à la commande concernée |
| `estLue` | boolean | Indique si la notification a été lue |
| `dateCreation` | timestamp | Date de création de la notification |

---

## Stack technique

| Domaine | Technologie |
|---------|-------------|
| Frontend | Flutter 3.47.2 / Dart 3.13.2 |
| Authentification | `firebase_auth` 6.6.1 |
| Base de données | `cloud_firestore` 6.9.0 |
| Initialisation Firebase | `firebase_core` 4.14.0 |
| Gestion d'état | `provider` 6.1.2 |
| Formatage | `intl` 0.19.0 |
| Chargement d'images | `cached_network_image` 3.4.1 |
| Tests | `flutter_test`, `mocktail` 1.0.4 |
| Lints | `flutter_lints` 6.0.0 |
| Intégration continue | GitHub Actions |

---

## Prérequis

- Flutter SDK 3.47.2 (canal stable).
- Git.
- Firebase CLI, pour lancer l'émulateur Firebase local.
- Un émulateur Android, un simulateur iOS ou un appareil physique.

---

## Installation

1. Cloner le dépôt :

   ```bash
   git clone https://github.com/DavFilsDev/quick-eat-app.git
   cd quick-eat-app
   ```

2. Installer les dépendances :

   ```bash
   flutter pub get
   ```

3. Démarrer l'émulateur Firebase local (terminal à laisser ouvert) :

   ```bash
   firebase emulators:start
   ```

   L'interface web de l'émulateur est accessible sur
   `http://127.0.0.1:4000`.

4. Lancer l'application :

   ```bash
   flutter run
   ```

---

## Configuration des environnements

Le comportement de l'application est piloté par des variables passées à la
compilation (`--dart-define`).

| Variable | Valeurs | Valeur par défaut | Description |
|----------|---------|-------------------|-------------|
| `USE_REAL_FIREBASE` | `true` / `false` | `false` | Utilise le projet Firebase réel au lieu de l'émulateur |
| `DEV_ROLE` | `student` / `merchant` | (vide) | Crée et connecte automatiquement un compte de test du rôle indiqué |
| `EMULATOR_HOST` | adresse IP ou hôte | `localhost` (`10.0.2.2` sur émulateur Android) | Adresse de l'hôte des émulateurs Firebase |

En mode debug et sans `USE_REAL_FIREBASE`, l'application cible automatiquement
les émulateurs locaux. Les données de démonstration sont injectées
automatiquement au démarrage si les collections sont vides
(`services/firestore_seed.dart`).

### Connexion automatique en développement

Pour éviter de passer par l'écran de connexion à chaque lancement :

```bash
flutter run --dart-define=DEV_ROLE=student
flutter run --dart-define=DEV_ROLE=merchant
```

### Appareil physique

Sur un appareil physique, l'hôte `localhost` n'est pas joignable. Indiquer
l'adresse IP locale de la machine :

```bash
hostname -I
flutter run --dart-define=EMULATOR_HOST=<adresse_ip> --dart-define=DEV_ROLE=student
```

### Projet Firebase réel

```bash
flutter run --dart-define=USE_REAL_FIREBASE=true
```

---

## Lancement

```bash
# Terminal 1
firebase emulators:start

# Terminal 2
flutter run
```

---

## Qualité et intégration continue

Avant toute pull request, exécuter les vérifications suivantes :

```bash
# Formatage du code
dart format .

# Analyse statique
flutter analyze

# Tests unitaires et de widgets
flutter test
```

Le workflow GitHub Actions
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) exécute ces trois
étapes sur chaque push et pull request vers `main`, avec Flutter 3.47.2.

---

## Tests

La suite de tests couvre les briques principales de l'application :

- Détection de rôle et validation des formulaires d'authentification.
- Sélecteur d'indicatif téléphonique africain et campus personnalisé.
- Contrôleur du catalogue (regroupement par commerçant, catégories, recherche).
- Contrôleur et modale de commande côté étudiant, carte de commande.
- Contrôleur des commandes côté commerçant.
- Formulaires, recherche, filtres, tri et contrôleur de gestion du menu.
- Notifications : contrôleur, écran d'historique, cloche et badge.
- Écrans de profil (affichage selon le rôle, déconnexion, préférence de
  notifications).
- Barre de navigation et données de démonstration.

```bash
flutter test
```

---

## Structure du projet

```text
lib/
├── main.dart                 # Point d'entrée, initialisation Firebase et seed
├── app.dart                  # MaterialApp, thème et routage
├── firebase_options.dart     # Configuration Firebase générée
├── core/
│   ├── auth/                 # AuthGate et connexion automatique de dev
│   ├── constants/            # Couleurs, styles, chemins Firestore
│   ├── errors/               # Failure et InvalidOrderTransition
│   ├── theme/                # Thème Material
│   ├── utils/                # Formatage FCFA et temps relatif
│   └── widgets/              # AppBar, boutons, vues de chargement et d'erreur
├── data/
│   └── repositories/         # Contrats et implémentations Firestore
├── models/
│   ├── enums/                # UserRole, OrderStatus, DeliveryType
│   └── *.dart                # UserModel, FoodModel, OrderModel, OrderItemModel, NotificationModel
├── features/
│   ├── auth/                 # Authentification, indicatifs et détection de rôle
│   ├── catalog/              # Accueil étudiant et détail restaurant
│   ├── menu_management/      # Gestion du menu commerçant (recherche, filtres, tri)
│   ├── notifications/        # Cloche, historique et contrôleur de notifications
│   ├── orders/               # Commandes étudiant et commerçant
│   ├── profile/              # Profil étudiant et commerçant
│   └── shell/                # Mise en page et navigation principale
├── mock/                     # Données de démonstration
├── routes/                   # Déclaration des routes
└── services/                 # Seed Firestore
```

---

## Documentation

- [`docs/mcd.md`](docs/mcd.md) : modèle conceptuel de données et schéma Firestore.
- [`docs/plan-sprint.md`](docs/plan-sprint.md) : organisation du sprint et
  environnement de développement local.
- [`docs/figma-mokups/`](docs/figma-mokups) : maquettes de référence de
  l'interface.

---

## Limitations connues et évolutions

- Les règles de sécurité Firestore autorisent actuellement tout utilisateur
  authentifié. Un durcissement par rôle (un étudiant ne modifie que ses propres
  commandes, un commerçant ne modifie que ses propres menus) est prévu.
- Il n'existe pas de panier persistant : la commande est créée directement
  depuis la fiche d'un plat.
- Le paiement en ligne n'est pas implémenté.
- Les notifications sont uniquement in-app : aucun envoi push système
  (Firebase Cloud Messaging) n'est implémenté.
- La suppression d'un plat est définitive, sans corbeille.
- Les images des plats sont fournies via une URL, sans téléversement de fichier.

---

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier
[`LICENSE`](LICENSE) pour plus de détails.
