# ImmoFaso 🏠
**Plateforme de gestion de location immobilière - Burkina Faso**

## Description
Application Flutter de mise en relation entre locataires et propriétaires au Burkina Faso. Couvre les logements (villas, appartements, cours communes, résidences) et les locaux commerciaux.

---

## 📁 Structure du projet
```
immofaso/
├── lib/
│   ├── main.dart                    ← Point d'entrée + navigation
│   ├── theme.dart                   ← Couleurs, thème, constantes
│   ├── models/
│   │   └── models.dart              ← Classes: Bien, Utilisateur, Contrat...
│   ├── providers/
│   │   └── providers.dart           ← AuthProvider, BienProvider (state)
│   ├── widgets/
│   │   └── widgets.dart             ← Composants réutilisables
│   └── screens/
│       ├── auth_screens.dart        ← Login + Inscription
│       ├── home_screen.dart         ← Accueil
│       ├── biens_screens.dart       ← Liste + Détail bien
│       └── profile_screen.dart      ← Profil + Publier bien
└── pubspec.yaml                     ← Dépendances
```

---

## 🚀 Installation

### Prérequis
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio ou VS Code

### Étapes
```bash
# 1. Cloner / copier le projet
cd immofaso

# 2. Installer les dépendances
flutter pub get

# 3. Créer les dossiers d'assets
mkdir -p assets/images assets/icons

# 4. Lancer l'app
flutter run
```

---

## ✨ Fonctionnalités implémentées

### 🔐 Authentification
- [x] Connexion (email + mot de passe)
- [x] Inscription (locataire / propriétaire)
- [x] Déconnexion
- [x] Parcourir sans compte

### 🏠 Biens immobiliers
- [x] Liste des biens en grille ou liste
- [x] Recherche par texte
- [x] Filtres: ville, type de location, prix max
- [x] Carousel de photos
- [x] Détail complet (description, caractéristiques, avis)
- [x] Système de notation (étoiles)

### 📅 Réservations & Visites
- [x] Réservation court terme (avec dates et calcul prix)
- [x] Choix du mode de paiement (Orange Money, Moov Money, Coris Money)
- [x] Demande de visite avec calendrier

### 📣 Publication
- [x] Formulaire de publication d'un bien (propriétaire)
- [x] Ajout de photos (interface)

### 🔔 Notifications
- [x] Centre de notifications avec badges

### 👤 Profil
- [x] Affichage infos utilisateur
- [x] Menu (visites, réservations, contrats, paiements)

---

## 🛠️ Dépendances principales

| Package | Utilisation |
|---------|-------------|
| `provider` | Gestion d'état |
| `go_router` | Navigation |
| `cached_network_image` | Images avec cache |
| `carousel_slider` | Slider photos |
| `flutter_rating_bar` | Étoiles de notation |
| `intl` | Format dates/nombres (fr_FR) |
| `url_launcher` | Appel téléphonique |
| `google_fonts` | Police Poppins |
| `image_picker` | Sélection photos |

---

## 🎨 Design
- **Couleur principale**: Vert #006B3F (inspiré du drapeau du Burkina Faso)
- **Couleur secondaire**: Or/Jaune #FFC107
- **Police**: Poppins (Google Fonts)
- **Style**: Material Design 3

---

## 📱 Écrans

| Écran | Description |
|-------|-------------|
| Login | Connexion email/mot de passe |
| Register | Inscription locataire ou propriétaire |
| Home | Accueil avec recherche, filtres, stats et liste |
| Biens | Tous les biens (grid/list view + filtres avancés) |
| Détail | Photos, info, caractéristiques, avis, appel |
| Profil | Compte, notifications, paramètres |

---

## 🔜 À développer (Phase 2)
- [ ] Intégration API REST (Node.js + PostgreSQL)
- [ ] Vraie intégration CinetPay (mobile money)
- [ ] Messagerie in-app propriétaire ↔ locataire
- [ ] Génération de contrats PDF
- [ ] Carte géographique des biens
- [ ] Admin panel
- [ ] Notifications push (Firebase)

---

## 👨‍💻 Développé pour ImmoFaso
Plateforme digitale de location immobilière pour le marché burkinabè.
Cible initiale: Ouagadougou & Bobo-Dioulasso.
