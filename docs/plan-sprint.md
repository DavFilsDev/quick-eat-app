# QuickEat — Plan de Sprint & Répartition d'Équipe
**Deadline : Mardi 15 Septembre avant 19h00 GMT — PR vers `main` + débriefing**

---

## Mise à jour — prérequis Lead terminés et mergés sur `main`
La branche `chore/tech-lead-bootstrap` a été mergée. Tout ce qui suit dans la
"Section 1" ci-dessous est **déjà fait** — gardé dans ce document pour que
chacun comprenne pourquoi le repo est structuré ainsi, pas comme une tâche à
refaire. Écarts avec le premier draft de ce plan, à connaître avant de
démarrer :

- `firebase_auth` est en version **`^6.6.1`** (pas `^5.3.1` comme prévu au
  départ — conflit de résolution avec `firebase_core ^4.14.0`, déjà présent
  dans le repo).
- **Un émulateur Firebase local (Firestore + Auth) est en place**, isolé par
  dev — voir "Travailler en local" plus bas. **Personne ne doit lancer l'app
  contre le vrai Firebase (`fscamp-app`) pendant le sprint**, sauf
  intégration finale explicitement décidée avec le Lead.
- **`login_screen.dart` et `register_screen.dart` existent déjà et
  fonctionnent réellement** (connexion/inscription Firebase + redirection
  automatique) — juste sans le design des maquettes. Dev 1 part de cette
  base, pas de zéro (voir sa fiche mise à jour).
- Un bug a été trouvé et corrigé en cours de route : `menu_repository.dart`
  écrivait `disponibilite` au lieu de `disponible` — déjà corrigé, à
  connaître si quelqu'un a une copie locale antérieure.

---
## État du dépôt au démarrage du sprint

La branche `chore/tech-lead-bootstrap` a été mergée dans `main`. Avant de démarrer votre tâche, faites `git pull` sur `main` et lisez ceci :

- **CI GitHub Actions active** (format / analyze / test) sur chaque PR vers `main`.
- **Repositories partagés déjà écrits et gelés** : `data/repositories/{auth,user,menu,order}_repository.dart`. Ne les modifiez pas sans concertation dans le channel d'équipe.
- **Toutes les routes déjà déclarées** dans `routes/app_router.dart` — ne touchez pas ce fichier, remplacez juste le contenu de votre(vos) écran(s) stub.
- **AuthGate déjà en place** (`core/auth/auth_gate.dart`) : redirige automatiquement vers l'accueil étudiant/commerçant selon le rôle une fois connecté.
- **Login/Register déjà fonctionnels mais minimalistes** (`features/auth/presentation/screens/`) : la connexion, l'inscription et l'écriture du doc `users/{uid}` marchent réellement. Ce n'est PAS encore au design de la maquette — c'est la tâche de Dev 1 de les améliorer, pas de les recréer.
- **Firestore Local Emulator Suite configuré** — voir section "Environnement de dev local" ci-dessous, à lire par tout le monde avant de lancer `flutter run`.

---

## Environnement de dev local — à lire avant votre premier `flutter run`

Chaque dev travaille sur **sa propre base de données locale** (émulateur Firebase), jamais sur le vrai projet `fscamp-app` — ça évite que vos commandes/menus de test changent sous les yeux d'un autre dev.

### Démarrage quotidien
```bash
firebase emulators:start          # terminal 1, à laisser ouvert
flutter run                       # terminal 2 — utilise l'émulateur PAR DÉFAUT, rien à préciser
```
Le seed (données de démo) s'exécute automatiquement à chaque lancement contre votre émulateur local. Interface web pour voir vos données : `http://127.0.0.1:4000`.

### Pour ne pas attendre l'écran de connexion à chaque fois
```bash
flutter run --dart-define=DEV_ROLE=student     # AKALETE Koffi Levis,  Achille MAZAMEZA
flutter run --dart-define=DEV_ROLE=merchant    # Branel ACCROMBESSY, Marie Michelle
```
Connecte/crée automatiquement un compte de test et saute direct à votre écran.

### Sur téléphone physique (pas un émulateur Android virtuel)
Nécessite une vraie IP LAN (téléphone et PC sur le même Wi-Fi) :
```bash
hostname -I                       # trouver l'IP de votre PC
flutter run --dart-define=EMULATOR_HOST=<votre_ip> --dart-define=DEV_ROLE=student
```
`localhost`/`127.0.0.1`/`adb reverse` ne fonctionnent PAS sur Android physique (le SDK Firebase les remappe automatiquement vers `10.0.2.2`, réservé à l'émulateur virtuel). En cas de souci de connexion, testez d'abord `http://<votre_ip>:4000` dans le navigateur du téléphone — si ça ne charge pas, c'est votre pare-feu (`sudo ufw allow 8080/tcp 9099/tcp 4000/tcp`) ou l'isolation Wi-Fi de votre routeur, pas un bug de l'app.

### Ne JAMAIS faire tourner l'app contre le vrai Firebase pendant le sprint
Un simple `flutter run` va déjà à l'émulateur par défaut — c'est volontaire, pour éviter tout risque. Le vrai `fscamp-app` (`--dart-define=USE_REAL_FIREBASE=true`) est réservé à l'intégration finale, juste avant la démo, une fois toutes les branches mergées.

---

## Section 1 — Actions du Lead (prérequis à pousser sur `main` avant le démarrage)

### 1.1 `pubspec.yaml` — dépendances à ajouter
```yaml
dependencies:
  firebase_auth: ^6.6.1   # ^5.3.1 prévu au départ, corrigé — voir note en haut du document
  provider: ^6.1.2
  intl: ^0.19.0
  cached_network_image: ^3.4.1

dev_dependencies:
  mocktail: ^1.0.4   # pour mocker les repositories dans les tests unitaires
```

### 1.2 Arborescence à créer (dossiers + fichiers vides `.gitkeep` où indiqué)
```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          (existe déjà — à compléter)
│   │   ├── app_text_styles.dart     (nouveau)
│   │   └── firestore_paths.dart     (nouveau — centralise les noms de collections)
│   ├── errors/
│   │   └── failures.dart            (nouveau)
│   ├── utils/
│   │   ├── currency_formatter.dart  (nouveau — formate en FCFA)
│   │   └── time_ago_formatter.dart  (nouveau — "Il y a 25 min")
│   ├── widgets/
│   │   ├── loading_view.dart
│   │   ├── error_view.dart
│   │   └── primary_button.dart
│   └── auth/
│       └── auth_gate.dart           (nouveau — voir 1.4)
├── data/
│   └── repositories/
│       ├── auth_repository.dart     (interface + impl Firebase Auth)
│       ├── user_repository.dart     (interface + impl Firestore `users`)b
│       ├── menu_repository.dart     (interface + impl Firestore `menus`)
│       └── order_repository.dart    (interface + impl Firestore `orders` + sous-collection `items`)
├── models/                          (existe déjà — inchangé, ne pas toucher)
├── features/
│   ├── auth/
│   │   ├── domain/.gitkeep
│   │   └── presentation/{screens,widgets,controllers}/.gitkeep
│   ├── catalog/
│   │   └── presentation/{screens,widgets,controllers}/.gitkeep
│   ├── orders/
│   │   └── presentation/
│   │       ├── student/{screens,widgets,controllers}/.gitkeep
│   │       └── merchant/{screens,widgets,controllers}/.gitkeep
│   ├── menu_management/
│   │   └── presentation/{screens,widgets,controllers}/.gitkeep
│   └── profile/
│       └── presentation/{screens,widgets}/.gitkeep
├── routes/app_router.dart           (existe déjà — Lead pré-câble TOUTES les routes, voir 1.5)
└── app.dart                         (existe déjà — modifié, voir 1.4)

.github/workflows/ci.yml             (nouveau)
test/features/... (miroir de lib/features/...)
```
Ces dossiers vides évitent que deux devs créent la même arborescence avec des noms légèrement différents lors du premier commit (source classique de conflit).

### 1.3 Repositories partagés (contrats figés — **personne d'autre n'édite ces 4 fichiers** sauf concertation dans le channel d'équipe)

```dart
// data/repositories/order_repository.dart (extrait de l'interface)
abstract class OrderRepository {
  Stream<List<OrderModel>> streamCommandesEtudiant(String idEtudiant);
  Stream<List<OrderModel>> streamCommandesCommercant(String idCommercant);
  Future<String> creerCommande(OrderModel commande);
  Future<void> mettreAJourStatut(String idCommande, OrderStatus statut);
  Future<void> annulerCommande(String idCommande); // refuse si statut != enAttente
}
```
Même logique pour `UserRepository` (CRUD `users/{userId}`, méthode `detecterRole(String email)` déléguée à `RoleDetector` du Dev1), `MenuRepository` (CRUD `menus/{menuId}`, filtre `merchantId`), `AuthRepository` (signIn/signUp/signOut/authStateChanges, enveloppe `firebase_auth`).

L'actuel `services/firestore_service.dart` est **splitté** dans ces 4 repositories puis supprimé par le Lead (garder son contenu comme référence de départ, il est déjà correct).

### 1.4 `core/auth/auth_gate.dart` + `app.dart`
`AuthGate` écoute `FirebaseAuth.instance.authStateChanges()` : si non connecté → `LoginScreen` ; si connecté → lit `users/{uid}` via `UserRepository` et redirige vers `studentHome` ou `merchantHome` selon `role`. `app.dart` devient :
```dart
MaterialApp(
  ...
  home: const AuthGate(),
  onGenerateRoute: AppRouter.generateRoute, // pour la navigation interne après connexion
)
```
Ça évite à chaque dev de retoucher `app.dart` : le point d'entrée est déjà résolu par le Lead.

### 1.5 `routes/app_router.dart` — toutes les routes pré-déclarées
Le Lead ajoute dès maintenant les constantes et les `case` pointant vers les classes que chaque dev va créer (noms de classes fixés à l'avance, voir Section 2). Tant qu'un dev n'a pas encore livré son écran, son `case` pointe vers un `Scaffold` placeholder généré automatiquement — donc **aucun dev ne touche `app_router.dart`**, ce fichier ne bouge plus après le prérequis.

### 1.6 `firestore.rules` (durcissement minimal, pas de rules par rôle fines pour l'instant — backlog post-deadline)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 1.7 `.github/workflows/ci.yml`
```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  format:
    name: Code Formatting
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Check code formatting
        run: dart format --output=none --set-exit-if-changed .

  analyze:
    name: Static Analysis
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

  test:
    name: Unit & Widget Tests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test
```

---

## Section 2 — Répartition pour 5 développeurs

### Lee Andriamaholison — Authentification & Détection de Rôle
- **Branche :** `feat/auth-onboarding`
- **Point de départ (déjà fait par le Lead, NE PAS repartir de zéro) :** `login_screen.dart` et `register_screen.dart` existent déjà et fonctionnent réellement (connexion, inscription, écriture du doc `users/{uid}`, toggle de rôle via `SegmentedButton`) — mais avec un design minimal, sans validations, sans dropdown campus. Votre tâche est d'**améliorer l'existant pour qu'il corresponde aux maquettes `connection`/`creation-de-compte`**, pas de recréer le flux depuis zéro.
- **Fonctionnalités à ajouter/améliorer :**
  Design conforme aux maquettes (champs stylés, texte d'accroche, lien mot de passe oublié), dropdown de campus (au lieu du texte en dur actuel), validations de formulaire (email valide, mot de passe ≥ 6 caractères avec indicateur de force, champs requis), formatage du numéro de téléphone (+229...), gestion d'erreurs plus fine (messages `FirebaseAuthException` traduits), et extraction de la logique métier (`_seConnecter`/`_creerCompte`) hors des widgets vers un `AuthController extends ChangeNotifier` — actuellement cette logique est directement dans les `State`, ce qui viole la règle "zéro logique métier dans les widgets".
- **Isolation des fichiers :**
  - Modifier : `lib/features/auth/presentation/screens/login_screen.dart`, `.../register_screen.dart` (existants, à faire évoluer, pas à réécrire l'architecture)
  - Créer : `lib/features/auth/presentation/widgets/role_toggle.dart` (extraire le `SegmentedButton`), `.../widgets/auth_text_field.dart`, `.../controllers/auth_controller.dart`, `lib/features/auth/domain/role_detector.dart` (détection de rôle par domaine email, en filet de sécurité derrière le toggle explicite déjà en place)
  - Ne pas modifier : `data/repositories/auth_repository.dart`, `user_repository.dart`, `routes/app_router.dart`, `core/auth/auth_gate.dart`
- **Bonnes pratiques :** toute la logique passe par `AuthController` (pas d'appel direct à `FirebaseAuth`/`AuthRepository` dans un widget), `const` sur les éléments statiques, gestion des états `Loading`/`Success`/`Error`.
- **Sous-tâches & tests :**
  - [ ] `RoleDetector` : test unitaire pur
  - [ ] Widget test : validation de formulaire (email invalide, mot de passe trop court)
  - [ ] Widget test : bascule du toggle Étudiant/Commerçant
  - [ ] Réintroduire un vrai smoke test dans `test/widget_test.dart` (actuellement réduit à un test trivial le temps du bootstrap — voir `TODO` dans le fichier) avec `AuthRepository`/`UserRepository` mockés via `mocktail`
- **Commits :**
  - `feat(auth): apply maquette design to login and register screens`
  - `refactor(auth): extract business logic into AuthController`
  - `feat(auth): add campus dropdown and form validation`
  - `test(auth): cover role detector and form validation`

### AKALETE Koffi Levis — Accueil Étudiant & Catalogue Restaurants/Menus
- **Branche :** `feat/student-catalog`
- **Fonctionnalités (maquettes `Accueil Étudiant`, `Détail Restaurant`) :**
  Écran d'accueil étudiant : barre de recherche, filtres par restaurant (`Tous` / `Chez Maman Tantie` / `Campus Grill`...), liste des plats disponibles (`menus` où `available == true`), liste des restaurants (dérivée des commerçants distincts ayant des menus). Écran détail restaurant : bannière, horaires (texte statique dérivé du profil commerçant), recherche interne, filtres par catégorie (`Salé`/`Sucré`), liste des plats de ce commerçant uniquement.
  Le bouton **"Commander"** n'ouvre PAS de logique de commande ici : il appelle une méthode statique exposée par le Dev 3 (`CreateOrderModal.show(context, food: food)`) — ce contrat est fixé dès maintenant pour éviter toute duplication de logique de commande.
- **Isolation des fichiers :**
  - Créer : `lib/features/catalog/presentation/screens/student_home_screen.dart`, `.../screens/restaurant_detail_screen.dart`, `.../widgets/food_card.dart`, `.../widgets/restaurant_card.dart`, `.../widgets/category_filter_chip.dart`, `.../controllers/catalog_controller.dart`
  - Ne pas modifier : `data/repositories/menu_repository.dart`, `user_repository.dart` (lecture seule)
- **Bonnes pratiques :** `catalog_controller.dart` s'abonne à `MenuRepository.streamMenus()`, filtre/recherche en mémoire (pas de re-query Firestore à chaque frappe), `dispose()` annule le `StreamSubscription`, `const` sur `FoodCard`/`RestaurantCard`.
- **Sous-tâches & tests :**
  - [ ] Widget test : filtrage par catégorie et recherche texte
  - [ ] Widget test : plat `disponibilite == false` n'apparaît pas ou apparaît grisé sans bouton "Commander"
  - [ ] Test contrôleur : regroupement des plats par `idCommercant` correct
- **Commits :**
  - `feat(catalog): add student home screen with search and filters`
  - `feat(catalog): add restaurant detail screen`
  - `test(catalog): cover menu filtering logic`

### Achille MAZAMEZA — Commandes Étudiant (Création & Suivi)
- **Branche :** `feat/student-orders`
- **Fonctionnalités (maquettes `Accueil Étudiant Modal Commande`, `Commandes Étudiant` + MCD) :**
  Modale de confirmation de commande : choix du mode de réception (`Livraison`/`Retrait` → `deliveryType`), sélecteur de quantité, calcul du montant total, création de la commande (`statut = EN_ATTENTE`). Écran "Mes Commandes" avec écoute temps réel (`streamCommandesEtudiant`) : pour une commande `LIVRAISON` passée à `LIVREE`... en fait c'est l'étudiant qui **confirme** le passage `EN_COURS_DE_LIVRAISON → LIVREE` (bouton "Confirmer la réception"). Pour `RETRAIT`, l'étudiant voit un badge informatif quand `statut == TERMINEE` ("Prêt à récupérer") mais **n'a aucune action** : c'est le commerçant qui confirme `RECU` à la remise physique (Dev 4). Règle stricte à implémenter même si absente du mockup fourni : bouton "Annuler la commande" visible **uniquement** si `statut == EN_ATTENTE` (utiliser `commande.peutEtreAnnulee`, déjà présent dans `OrderModel`, ne pas dupliquer cette logique dans le widget).
- **Isolation des fichiers :**
  - Créer : `lib/features/orders/presentation/student/widgets/create_order_modal.dart`, `.../screens/student_orders_screen.dart`, `.../widgets/order_card_student.dart`, `.../controllers/student_orders_controller.dart`
  - Ne pas modifier : `data/repositories/order_repository.dart`, `lib/models/order_model.dart` (réutiliser `peutEtreAnnulee`)
- **Bonnes pratiques :** aucune logique de transition de statut recopiée dans le widget (toujours via `OrderModel`/`OrderRepository`), gestion des états `Loading`/`Success`/`Error` explicite dans `student_orders_controller.dart`, `try/catch` sur `FirebaseException` à la création de commande, annulation du listener dans `dispose()`.
- **Sous-tâches & tests :**
  - [ ] Test : le bouton "Annuler" n'apparaît pas si `statut != EN_ATTENTE`
  - [ ] Test : le bouton "Confirmer la réception" n'apparaît que pour `LIVRAISON` + `EN_COURS_DE_LIVRAISON`
  - [ ] Test : calcul du montant total dans la modale (quantité × prix unitaire)
  - [ ] Widget test de la modale de commande (ouverture/fermeture, validation)
- **Commits :**
  - `feat(orders): add order creation modal for students`
  - `feat(orders): add student orders screen with realtime status`
  - `fix(orders): enforce cancellation only from EN_ATTENTE`

### Branel ACCROMBESSY — Espace Commerçant : Dashboard & Traitement des Commandes
- **Branche :** `feat/merchant-orders-dashboard`
- **Fonctionnalités (maquettes `Accueil Commerçant`, `Détails Commande Commerçant` + MCD) :**
  Liste des commandes reçues par le commerçant (`streamCommandesCommercant`), triée **de la plus ancienne à la plus récente** (badge "il y a X min" via `time_ago_formatter.dart` fourni par le Lead), badge de statut coloré, compteur "en cours". Écran détail commande : barre de progression du statut, infos client (nom, campus/adresse), plats commandés, montant total, et **bouton d'action dynamique** vers l'étape suivante en s'appuyant sur `OrderModel.statutsMarchand` (déjà calculé selon `deliveryType`) : `EN_ATTENTE → ACCEPTEE`, puis `ACCEPTEE → EN_COURS_DE_LIVRAISON` (livraison) ou `ACCEPTEE → TERMINEE` (retrait), puis pour le retrait uniquement `TERMINEE → RECU` (confirmé par le commerçant à la remise). Pas de bouton d'action quand la prochaine étape dépend de l'étudiant (`EN_COURS_DE_LIVRAISON → LIVREE`).
- **Isolation des fichiers :**
  - Créer : `lib/features/orders/presentation/merchant/screens/merchant_home_screen.dart`, `.../screens/merchant_order_detail_screen.dart`, `.../widgets/order_status_badge.dart`, `.../widgets/order_progress_bar.dart`, `.../controllers/merchant_orders_controller.dart`
  - Ne pas modifier : `data/repositories/order_repository.dart`, `lib/models/order_model.dart`
- **Bonnes pratiques :** le libellé du bouton ("Passer à : Accepté", etc.) se déduit du prochain élément de `statutsMarchand`, jamais codé en dur par écran ; `const` sur les badges ; gestion d'erreur si la mise à jour de statut échoue (`FirebaseException` → `SnackBar`).
- **Sous-tâches & tests :**
  - [ ] Test : libellé et statut cible du bouton d'action pour chaque combinaison `deliveryType`/`statut`
  - [ ] Test : aucun bouton affiché quand l'action suivante appartient à l'étudiant
  - [ ] Test : tri des commandes par ancienneté croissante
  - [ ] Widget test de l'écran détail (rendu de la barre de progression)
- **Commits :**
  - `feat(orders): add merchant orders dashboard`
  - `feat(orders): add merchant order detail with status actions`
  - `test(orders): cover next-status resolution for delivery and pickup`

### Nouvelle membre (Marie Michelle) — Gestion des Menus (CRUD Commerçant) & Profils
- **Branche :** `feat/menu-management-profiles`
- **Fonctionnalités (maquettes `Profil Commerçant`, `Profil Étudiant` + CRUD menu, MCD) :**
  Écran de gestion des plats côté commerçant : liste de ses menus (`merchantId == currentUser`), ajout/édition (nom, description, prix, catégorie, URL image — **pas d'upload de fichier pour tenir la deadline**, juste un champ texte pour `imageUrl`), toggle `disponibilite`. Écrans profils étudiant et commerçant : affichage des infos (`nomComplet`, email, téléphone, rôle, campus), bouton "Se déconnecter" (`AuthRepository.signOut()`).
- **Isolation des fichiers :**
  - Créer : `lib/features/menu_management/presentation/screens/merchant_menu_screen.dart`, `.../widgets/menu_form_dialog.dart`, `.../widgets/menu_item_tile.dart`, `.../controllers/menu_management_controller.dart`, `lib/features/profile/presentation/screens/student_profile_screen.dart`, `.../screens/merchant_profile_screen.dart`, `.../widgets/profile_info_tile.dart`
  - Ne pas modifier : `data/repositories/menu_repository.dart`, `auth_repository.dart`, `user_repository.dart`
- **Bonnes pratiques :** validation de formulaire (prix > 0, nom non vide) avant écriture Firestore, `const` sur `ProfileInfoTile`/`MenuItemTile`, confirmation (dialogue) avant suppression d'un plat, gestion des erreurs d'écriture.
- **Sous-tâches & tests :**
  - [ ] Test : validation du formulaire menu (prix négatif ou nul rejeté)
  - [ ] Test : toggle disponibilité met bien à jour Firestore via le repository (mock)
  - [ ] Widget test des deux écrans de profil (affichage correct selon le rôle)
  - [ ] Test : déconnexion redirige vers `AuthGate`/écran de connexion
- **Commits :**
  - `feat(menu): add merchant menu CRUD screen`
  - `feat(profile): add student and merchant profile screens`
  - `fix(menu): validate price and name before saving`

---

## Règle de coordination transverse
Les 4 fichiers de `data/repositories/` et `routes/app_router.dart` sont **gelés** après le prérequis Lead. Si un dev a besoin d'une méthode supplémentaire dessus, il l'ajoute dans une **PR séparée et minuscule**, signalée dans le channel d'équipe, mergée en priorité avant de continuer — jamais mélangée à sa PR de feature.
Le fichier `test/widget_test.dart` a été temporairement réduit à un test trivial pendant le bootstrap (voir `TODO` dedans) — c'est Dev 1 qui le complète en même temps que son `AuthController`, pas un oubli à signaler.
