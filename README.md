# Movix

Application mobile **Flutter** (Android & iOS) pour la gestion des tournées, livraisons, pharmacies et commandes, avec intégration API et stockage local hors-ligne.

---

## 🚀 Fonctionnalités principales

- **Authentification sécurisée** (login avec token Bearer)  
- **Tableau de bord utilisateur** avec navigation fluide (GoRouter)  
- **Gestion des tournées :**
  - Chargement (`/chargement`)
  - Livraison (`/livraison`)
- **Scanner caméra unifié** (Android/iOS) basé sur Mobile Scanner  
- **Mode hors-ligne** avec Hive pour persistance locale  
- **Système audio** avec packs de sons (basic, mario, minecraft, pokemon, streetfighter)  
- **Thème sombre et clair dynamique**  
- **Support multilingue** (FR principalement)  

---

## 🛠️ Technologies utilisées

- **Flutter 3.32.0** (Dart 3.8.0)  
- **State Management** : Riverpod + Hive  
- **Navigation** : GoRouter avec guards  
- **HTTP client** : Dio  
- **Local storage** : Hive (avec génération de code)  
- **Camera** : Unified Camera System (voir `CAMERA_SYSTEM_README.md`)  

---

## 📂 Architecture du projet

lib/
├── API/ # Communication avec l’API (fetchers modulaires)
├── Models/ # Modèles de données (Hive objects)
├── Managers/ # Gestionnaires de logique métier & workflows
├── Services/ # Services globaux (auth, settings, etc.)
├── Pages/ # Écrans UI (par fonctionnalité)
├── Widgets/ # Composants UI réutilisables
├── Scanning/ # Système de scan caméra unifié
├── Router/ # Configuration GoRouter
└── main.dart # Point d’entrée de l’application

---

## ⚡ Commandes utiles

### Build & Run
```bash
# Lancer l’application
flutter run

# Build APK release
flutter build apk --release

# Build APK debug
flutter build apk --debug

## Tests & Analyse

# Lancer tous les tests
flutter test

# Lancer un test spécifique
flutter test test/widget_test.dart

# Analyse du code
flutter analyze

# Formatage du code
flutter format lib/
