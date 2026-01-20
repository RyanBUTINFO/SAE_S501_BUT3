# 🥗 Miaam — SAE BUT3

> **Réduction du gaspillage & Cuisine durable** > Une application mobile intelligente alignée avec l’**ODD 12** (Consommation et production responsables).

---

## 📝 Présentation
Miaam est une solution mobile conçue pour lutter contre le gaspillage alimentaire à l'échelle individuelle. L'application transforme les contraintes du quotidien (restes de frigo) en opportunités culinaires, tout en sensibilisant l'utilisateur à son **empreinte carbone**.

---

## 👥 L'Équipe
* **Ayoub Jemaa** | **Wajdi Ben Ouirane** | **Kevin Rodrigues**
* **Mouhammed Diop** | **Ryan Agin** | **Ciffedinne Mahdjoub**

---

## 🎯 Thématique & Objectifs
L'application s'inscrit dans une démarche de **développement durable** avec trois objectifs majeurs :
1. **Éco-responsabilité :** Réduction du gaspillage via une recommandation intelligente de recettes basée sur les stocks réels.
2. **Sensibilisation :** Éducation à l'impact écologique via le calcul de l'empreinte carbone des plats.
3. **Optimisation :** Offrir une expérience utilisateur fluide pour transformer la gestion des restes en réflexe quotidien.

---

## 🧠 Intelligence Artificielle & Algorithmes
Le moteur de recommandation ne se contente pas de filtres basiques, il utilise des concepts avancés de Data Science :
* **Modèle Vectoriel :** Représentation mathématique des ingrédients et recettes pour calculer des scores de similarité.
* **SVD (Singular Value Decomposition) :** Algorithme de décomposition matricielle utilisé pour traiter les caractéristiques latentes et optimiser la pertinence des suggestions.
* **Hybridation :** Mix entre filtrage par contenu (ingrédients disponibles) et préférences utilisateurs (historique et favoris).

---

## ✨ Fonctionnalités Principales
* **"Miracle du Frigo" :** Saisie dynamique des ingrédients disponibles.
* **Recommandation Intelligente :** Algorithmes entraînés sur des datasets **Kaggle** et **Zenodo**.
* **Eco-Score :** Estimation de l’empreinte carbone affichée sur chaque fiche recette.
* **Parcours Utilisateur Complet :** * Tutoriel vidéo en page d'accueil.
    * Recherche multi-critères (origine, salé/sucré, ustensiles).
    * Système de favoris et listes personnalisées.
    * Historique des dernières actions pour une reprise rapide.

---

## 🛠️ Stack Technique & Architecture
* **Frontend :** `Flutter` (Thème **Vert Kaki 🌿** pour une identité visuelle forte).
* **Backend :** `ExpressJS`.
* **Base de Données :** `Sqflite` avec une structure **dénormalisée** (optimisation des performances de lecture).
* **Machine Learning :** Algorithmes implémentés nativement en `Dart`.
* **Versioning :** Workflow `Git / GitHub`.

---

## 📊 Modélisation & Structure
### Modélisation UML
* **Cas d’utilisation :** Saisie, filtrage, gestion des favoris.
* **Diagramme de classe :** Architecture centrée sur les entités `Utilisateur`, `Recette`, `Ingrédient`, `Favori`.
* **Diagramme de séquence :** Focus sur le flux de recommandation et l'enregistrement des données.

### Sources de données
* **Dataset principal :** [Zenodo Records 15169428](https://zenodo.org/records/15169428).
* **Datasets complémentaires :** Intégration de données Kaggle pour les valeurs nutritionnelles et carbones.

---

## 📈 Analyse Critique
### ✅ Atouts
* Impact environnemental concret et mesurable.
* Interface intuitive (UX fluide).
* Grande scalabilité (possibilité d'ajouter de nouvelles sources de données).

### ⚠️ Défis & Inconvénients
* Complexité de gestion des ingrédients ambigus (homonymes).
* Optimisation continue du modèle de recommandation vectoriel.
* Maintien de l'engagement utilisateur sur le long terme.

---

## 📄 Licence
Ce projet est distribué sous licence **MIT**. Voir le fichier `LICENSE` pour plus d'informations.
