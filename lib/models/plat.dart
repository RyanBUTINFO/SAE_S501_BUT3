import 'ingredient_recette.dart';

class Plat {
  final int? id;
  final String nom;
  final String? type;
  final String? cuisine;
  final String? origine;
  final double? tempsPreparation;
  final double? tempsCuisson;
  final int? nbPersonnes;
  final int? nombreEtapes;
  final String? instructions;
  final String? methodesCuisson;
  final String? ustensiles;
  final String? imagePath;
  final double? calories;
  final String? valeurNutritionnelle;
  final double? empreinteCarbone;

  // Champs gérés hors SQL direct (Vecteurs et Relation Ingrédients)
  List<IngredientRecette> ingredients; 
  List<double> vector = []; 

  Plat({
    this.id, 
    required this.nom, 
    this.type, 
    this.cuisine, 
    this.origine,
    this.tempsPreparation, 
    this.tempsCuisson,
    this.nbPersonnes,
    this.nombreEtapes,
    this.instructions,
    this.methodesCuisson,
    this.ustensiles,
    this.imagePath,
    this.calories,
    this.valeurNutritionnelle,
    this.empreinteCarbone,
    this.ingredients = const [], 
  });

  factory Plat.fromMap(Map<String, dynamic> map) {
    // --- FONCTION INTERNE POUR RECHERCHER UNE CLÉ SANS SE SOUCIER DE LA CASSE ---
    // (Règle les problèmes de "valeur_nutritionnelle" vs "Valeur_Nutritionnelle")
    dynamic _get(String key) {
      final searchKey = key.toLowerCase().trim();
      for (var entry in map.entries) {
        if (entry.key.toLowerCase().trim() == searchKey) {
          return entry.value;
        }
      }
      return null;
    }

    // --- CONVERTISSEURS DE TYPES SÉCURISÉS ---
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return Plat(
      // Mappe 'plat_id' ou 'id' selon ce qui arrive de la base
      id: _toInt(_get('plat_id') ?? _get('id')),
      nom: (_get('nom') ?? 'Sans nom').toString(),
      type: _get('type')?.toString(),
      cuisine: _get('cuisine')?.toString(),
      origine: _get('origine')?.toString(),
      tempsPreparation: _toDouble(_get('temps_preparation')),
      tempsCuisson: _toDouble(_get('temps_cuisson')),
      nbPersonnes: _toInt(_get('nb_personnes')),
      nombreEtapes: _toInt(_get('nombre_etapes')),
      instructions: _get('instructions')?.toString(),
      methodesCuisson: _get('methodes_cuisson')?.toString(),
      ustensiles: _get('ustensiles')?.toString(),
      imagePath: _get('image_path')?.toString(),
      calories: _toDouble(_get('calories')),
      valeurNutritionnelle: _get('valeur_nutritionnelle')?.toString(),
      empreinteCarbone: _toDouble(_get('empreinte_carbone')),
      ingredients: [], // Rempli ultérieurement par hydraterIngredients()
    );
  }

  // Optionnel : Pour faciliter le débuggage dans la console
  @override
  String toString() => 'Plat(id: $id, nom: $nom, nutri: $valeurNutritionnelle)';
}