// fichier: ingredient_recette.dart

class IngredientRecette {
  // Le nom de l'ingrédient (vient de la table Ingredient)
  final String nomIngredient; 
  
  // La quantité utilisée (vient de la table Plat_ingredient)
  final double? quantite;      
  
  // L'unité de mesure (vient de la table Plat_ingredient)
  final String? unite;         

  IngredientRecette({
    required this.nomIngredient, 
    this.quantite, 
    this.unite,
  });

  /// Factory pour créer un objet IngredientRecette à partir du Map 
  /// retourné par la requête JOIN dans le Repository.
  factory IngredientRecette.fromMap(Map<String, dynamic> map) {
    return IngredientRecette(
      // Nous utilisons 'nom' car c'est le champ que la requête JOIN va sélectionner
      nomIngredient: map['nom'] as String, 
      
      // Gère la conversion de type car Sqflite peut renvoyer int ou double pour REAL
      quantite: map['quantite'] != null 
                ? (map['quantite'] as num).toDouble() 
                : null,
                
      unite: map['unite'] as String?,
    );
  }
}