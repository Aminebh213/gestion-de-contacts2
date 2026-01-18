# 📱 Application Mobile de Gestion de Contacts

## 📌 Description
Cette application permet de gérer des contacts via une application mobile Flutter connectée à une API REST développée avec FastAPI.

Les fonctionnalités principales sont :
- Ajouter un contact
- Afficher la liste des contacts
- Supprimer un contact par glissement

Chaque contact contient :
- Nom
- Prénom
- Numéro de téléphone (unique)

---

## 🧱 Architecture du Projet
projet/
├── backend/
│ ├── main.py
│ ├── models.py
│ ├── database.py
│ └── requirements.txt
│
├── mobile/
│ ├── lib/
│ │ ├── main.dart
│ │ ├── models/
│ │ │ └── person.dart
│ │ ├── services/
│ │ │ └── api_service.dart
│ │ └── screens/
│ │ ├── home_screen.dart
│ │ └── add_person_screen.dart
│ └── pubspec.yaml
│
└── README.md

---

## ⚙️ Technologies Utilisées

### Backend
- FastAPI
- SQLAlchemy
- SQLite
- Pydantic
- Uvicorn

### Frontend
- Flutter
- Dart
- HTTP

---

## 🚀 Installation et Exécution

### Backend (FastAPI)
```bash
cd backend
pip install -r requirements.txt
python main.py

## Documentation de l’API :
http://localhost:8000/docs

cd mobile
flutter pub get
flutter run

🔄 Fonctionnalités

Ajout d’un contact avec validation

Affichage de la liste des contacts

Suppression d’un contact par glissement

Gestion des erreurs

Indicateur de chargement

Message si aucun contact n’existe

🧪 Tests

Ajout d’un contact valide

Numéro de téléphone unique

Suppression d’un contact

Affichage dynamique de la liste

Gestion du cas liste vide

🧠 Choix Techniques

FastAPI pour une API rapide et documentée automatiquement

SQLite pour une base de données légère

Flutter pour une application mobile multiplateforme

Séparation backend / frontend pour une meilleure maintenabilité

