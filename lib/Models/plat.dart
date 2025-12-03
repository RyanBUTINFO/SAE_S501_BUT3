import 'ingredient_recette.dart'; // IMPORTANT : Assurez-vous d'importer la nouvelle classe

class Plat {
  // Propriétés de la BDD (finales)
  final int? id;
  final String? nom;
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
  final String? calories;
  final String? valeurNutritionnelle;
  final double? empreinteCarbone;

  // Propriété pour la page de détails (non-final, car hydratée après fromMap)
  // Elle contiendra la liste des ingrédients du plat avec quantité et unité.
  List<IngredientRecette> ingredientsRecette = []; 

  // Attributs additionnels/alias pour l'app
  String? instructionsText; // <--- LIGNE EXISTANTE
  String? image; 
  String? title; 
  String? level; 
  String? context; 

  Plat({
    this.id,
    this.nom,
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
    this.image,
    this.title,
    this.level,
    this.context,
    // Note: pas besoin d'inclure 'ingredientsRecette' dans le constructeur
    // car elle est initialisée à une liste vide par défaut.
  });

  factory Plat.fromMap(Map<String, dynamic> map) {
    String? _safeToString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }

    // Le 'fromMap' gère uniquement les données provenant de la table 'Plats'
    return Plat(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()),
      nom: _safeToString(map['nom']),
      type: _safeToString(map['type']),
      cuisine: _safeToString(map['cuisine']),
      origine: _safeToString(map['origine']),
      tempsPreparation: (map['temps_preparation'] is num)
          ? (map['temps_preparation'] as num).toDouble()
          : double.tryParse(map['temps_preparation'].toString()),
      tempsCuisson: (map['temps_cuisson'] is num)
          ? (map['temps_cuisson'] as num).toDouble()
          : double.tryParse(map['temps_cuisson'].toString()),
      nbPersonnes: map['nb_personnes'] is int
          ? map['nb_personnes'] as int
          : int.tryParse(map['nb_personnes'].toString()),
      nombreEtapes: map['nombre_etapes'] is int
          ? map['nombre_etapes'] as int
          : int.tryParse(map['nombre_etapes'].toString()),
      
      instructions: _safeToString(map['instructions']),
      methodesCuisson: _safeToString(map['methodes_cuisson']),
      ustensiles: _safeToString(map['ustensiles']),
      imagePath: _safeToString(map['image_path']),
      
      calories: _safeToString(map['calories']),
      
      valeurNutritionnelle: _safeToString(map['valeur_nutritionnelle']),
      empreinteCarbone: (map['empreinte_carbone'] is num)
          ? (map['empreinte_carbone'] as num).toDouble()
          : double.tryParse(map['empreinte_carbone'].toString()),
          
      // Initialisation des alias
      image: _safeToString(map['image_path']),
      title: _safeToString(map['nom']),
      level: _safeToString(map['type']),
      context: _safeToString(map['instructions']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'type': type,
      'cuisine': cuisine,
      'origine': origine,
      'temps_preparation': tempsPreparation,
      'temps_cuisson': tempsCuisson,
      'nb_personnes': nbPersonnes,
      'nombre_etapes': nombreEtapes,
      'instructions': instructions,
      'methodes_cuisson': methodesCuisson,
      'ustensiles': ustensiles,
      'image_path': imagePath,
      'calories': calories,
      'valeur_nutritionnelle': valeurNutritionnelle,
      'empreinte_carbone': empreinteCarbone,
      // NOTE: 'ingredientsRecette' n'est PAS inclus dans toMap
      // car il n'est pas censé être écrit directement dans la table 'Plats'.
    };
  }
}