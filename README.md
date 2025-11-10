# Miaam – SAE BUT3

## Présentation

Miaam est une application mobile intelligente qui aide les utilisateurs à réduire leur gaspillage alimentaire. L’application recommande des recettes pertinentes en fonction des ingrédients disponibles à la maison et calcule l’empreinte carbone de chaque plat pour favoriser des choix durables.

## Équipe

- Ayoub Jemaa
- Wajdi Ben Ouirane
- Kevin Rodrigues
- Mouhammed Diop
- Ryan Agin
- Ciffedinne Mahdjoub

## Thématique & Objectifs

- Réduction du gaspillage alimentaire via une recommandation intelligente de recettes.
- Alignement avec l’ODD 12 (Consommation et production responsables).
- Sensibilisation à l’impact écologique des choix alimentaires.

## Fonctionnalités principales

- Saisie des ingrédients disponibles (ex : riz, œuf, carotte).
- Filtres de recherche : origine géographique, type salé/sucré, barre de recherche.
- Recommandation de recettes personnalisées et pertinentes depuis les datasets Kaggle.
- Affichage des recettes avec :
  - Estimation de l’empreinte carbone
  - Méthode de préparation et liste d’ustensiles nécessaires
  - Favoris personnalisés et listes enregistrées
  - Historique des recettes préférées
- Interface intuitive, moderne et personnalisable

## Architecture et Technologies

- **Frontend (dossier `Front/`)** : Flutter (multiplateforme, interface fluide)
- **Backend** : Express.js (Node.js)
- **Base de données** : PostgreSQL
- **Machine Learning** : Scikit-learn, Pandas
- **Versioning** : Git & GitHub

## Parcours Utilisateur

1. Page d’accueil : Tutoriel vidéo
2. Saisie des ingrédients ou reprise de la dernière action
3. Mode découverte / personnalisé : Filtres et barre de recherche
4. Page des favoris : Listes et titres personnalisés

## Maquette & Design

- Thème visuel : Vert kaki
- Pages principales :
  - Accueil (tutoriel vidéo)
  - Formulaire de saisie
  - Mode découverte/personnalisé
  - Favoris

## Modélisation & Structure BDD

- Diagramme de cas d’utilisation : Saisie, filtrage, favoris
- Diagramme de classe : Recette, Utilisateur, Ingrédient, Favori
- Diagramme de séquence : Recommandation, Enregistrement
- Tables principales : utilisateurs, recettes, ingrédients, favoris, listes personnalisées
- Dénormalisation pour optimiser les performances des requêtes

## Jeux de données Kaggle utilisés

- [FoodCom Recipes and Reviews](https://www.kaggle.com/datasets/irkaal/foodcom-recipes-and-reviews)
- [Food Waste Dataset](https://www.kaggle.com/datasets/joebeachcapital/food-waste)
- [Food Carbon Footprint](https://www.kaggle.com/datasets/francoisrachon/food-carbon-footprint)

## Avantages

- Impact environnemental concret et éducatif
- Application enrichissable avec de nouvelles sources
- Compatibilité avec les données ouvertes Kaggle
- Interface adaptative et parcours utilisateur fluide

## Inconvénients

- Gestion des ingrédients incomplets ou ambigus
- Optimisation du modèle de recommandation nécessaire
- Maintien de l’engagement utilisateur (UX)
- Gestion complexe des listes de favoris multiples et titres personnalisés

---

### Structure du dépôt

