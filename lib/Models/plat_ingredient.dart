class PlatIngredient {
  int platId;
  int ingredientId;
  double? quantite;
  String? unite;

  PlatIngredient({
    required this.platId,
    required this.ingredientId,
    this.quantite,
    this.unite,
  });

  factory PlatIngredient.fromMap(Map<String, dynamic> map) {
    return PlatIngredient(
      platId: map['plat_id'] as int,
      ingredientId: map['ingredient_id'] as int,
      quantite: map['quantite'] != null ? (map['quantite'] as num).toDouble() : null,
      unite: map['unite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plat_id': platId,
      'ingredient_id': ingredientId,
      'quantite': quantite,
      'unite': unite,
    };
  }
}
