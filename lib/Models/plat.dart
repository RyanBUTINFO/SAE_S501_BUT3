class Plat {
  final int? id;
  final String? nom;
  final String? type;
  final String? cuisine;   
  final String? origine;   
  final double? preparationTime;
  final double? cookingTime;
  final int? nbPersonnes;
  final int? numberOfSteps;
  final String? instructionsText;
  final String? cookingMethods;
  final String? ustensiles;
  final String? imagePath;
  final String? calories;
  final String? valeurNutritionnelle;
  final double? empreinteCarbone;

  Plat({
    this.id,
    this.nom,
    this.type,
    this.cuisine,
    this.origine,
    this.preparationTime,
    this.cookingTime,
    this.nbPersonnes,
    this.numberOfSteps,
    this.instructionsText,
    this.cookingMethods,
    this.ustensiles,
    this.imagePath,
    this.calories,
    this.valeurNutritionnelle,
    this.empreinteCarbone,
  });

  factory Plat.fromMap(Map<String, dynamic> map) {
    return Plat(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()),
      nom: map['nom'] as String?,
      type: map['type'] as String?,
      cuisine: map['cuisine'] as String?,
      origine: map['origine'] as String?,
      preparationTime: (map['preparation_time'] is num)
          ? (map['preparation_time'] as num).toDouble()
          : double.tryParse(map['preparation_time'].toString()),
      cookingTime: (map['cooking_time'] is num)
          ? (map['cooking_time'] as num).toDouble()
          : double.tryParse(map['cooking_time'].toString()),
      nbPersonnes: map['nb_personnes'] is int
          ? map['nb_personnes'] as int
          : int.tryParse(map['nb_personnes'].toString()),
      numberOfSteps: map['number_of_steps'] is int
          ? map['number_of_steps'] as int
          : int.tryParse(map['number_of_steps'].toString()),
      instructionsText: map['instructions_text'] as String?,
      cookingMethods: map['cooking_methods'] as String?,
      ustensiles: map['ustensiles'] as String?,
      imagePath: map['image_path'] as String?,
      calories: map['Calories'] as String?,
      valeurNutritionnelle: map['Valeur_nutritionnelle'] as String?,
      empreinteCarbone: (map['empreinte_carbone'] is num)
          ? (map['empreinte_carbone'] as num).toDouble()
          : double.tryParse(map['empreinte_carbone'].toString()),
    );
  }
}
