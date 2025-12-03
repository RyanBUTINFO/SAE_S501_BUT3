class Plat {
  String? instructionsText; // <--- AJOUTER CETTE LIGNE
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

  // Attributs additionnels pour l'app
  String? image;    // alias pour imagePath
  String? title;    // alias pour nom
  String? level;    // alias pour type
  String? context;  // alias pour instructions

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
  });

  factory Plat.fromMap(Map<String, dynamic> map) {
    // Fonction utilitaire pour convertir toute valeur en String? ou null
    // Cela corrige l'erreur "type 'double' is not a subtype of type 'String?'"
    String? _safeToString(dynamic value) {
      if (value == null) return null;
      // Si c'est déjà une String, la retourner.
      if (value is String) return value;
      // Si c'est un nombre (int, double, num), le convertir en String.
      return value.toString();
    }

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
      
      // Les champs TEXTE sont désormais convertis de manière sécurisée
      instructions: _safeToString(map['instructions']),
      methodesCuisson: _safeToString(map['methodes_cuisson']),
      ustensiles: _safeToString(map['ustensiles']),
      imagePath: _safeToString(map['image_path']),
      
      // Correction critique pour "double" en "String"
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
    };
  }
}