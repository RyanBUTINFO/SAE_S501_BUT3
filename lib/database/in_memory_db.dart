import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class InMemoryDatabase {
  static final InMemoryDatabase _instance = InMemoryDatabase._internal();
  
  late List<Map<String, dynamic>> ingredients;
  late List<Map<String, dynamic>> plats;
  late List<Map<String, dynamic>> platIngredients;
  
  bool isLoaded = false;

  InMemoryDatabase._internal();
  factory InMemoryDatabase() => _instance;

  Future<void> init() async {
    if (isLoaded) return;
    
    try {
      // Charger les ingrédients
      final ingredientsStr = await rootBundle.loadString('Csv_database/ingredients.csv');
      final ingredientsList = const CsvToListConverter().convert(ingredientsStr);
      ingredients = ingredientsList.skip(1).map((row) {
        return {
          'id': int.parse(row[0].toString()),
          'nom': row[1].toString().trim().toLowerCase(),
        };
      }).toList();

      // Charger les plats
      final platsStr = await rootBundle.loadString('Csv_database/plats.csv');
      final platsList = const CsvToListConverter().convert(platsStr);
      plats = platsList.skip(1).map((row) {
        return {
          'plat_id': int.parse(row[0].toString()),
          'nom': row[1].toString(),
          // Ajouter les autres colonnes au besoin
        };
      }).toList();

      // Charger les relations plat-ingrédient
      final platIngStr = await rootBundle.loadString('Csv_database/plat_ingredient.csv');
      final platIngList = const CsvToListConverter().convert(platIngStr);
      platIngredients = platIngList.skip(1).map((row) {
        return {
          'plat_id': int.parse(row[0].toString()),
          'ingredient_id': int.parse(row[1].toString()),
        };
      }).toList();

      isLoaded = true;
      print('✅ Base de données en mémoire chargée');
    } catch (e) {
      print('❌ Erreur chargement BD: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> searchIngredients(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 1) return [];
    return ingredients.where((ing) => 
      ing['nom'].contains(q)
    ).toList();
  }

  List<Map<String, dynamic>> getPlatsByIds(List<int> ids) {
    if (ids.isEmpty) return [];
    return plats.where((p) => ids.contains(p['plat_id'])).toList();
  }

  List<Map<String, dynamic>> getPlatsByIngredients(List<int> ingredientIds) {
    if (ingredientIds.isEmpty) return [];
    
    // Optimisation : créer un map des ingrédients par plat
    final Map<int, Set<int>> platIngredientsMap = {};
    
    for (var pi in platIngredients) {
      final platId = pi['plat_id'] as int;
      final ingId = pi['ingredient_id'] as int;
      
      if (!platIngredientsMap.containsKey(platId)) {
        platIngredientsMap[platId] = {};
      }
      platIngredientsMap[platId]!.add(ingId);
    }
    
    // Trouver les plats contenant TOUS les ingrédients sélectionnés
    final Set<int> userIngredients = ingredientIds.toSet();
    final validPlats = <int>[];
    
    for (var platId in platIngredientsMap.keys) {
      final platIngs = platIngredientsMap[platId]!;
      // Vérifier si tous les ingrédients sélectionnés sont dans ce plat
      if (userIngredients.every((ingId) => platIngs.contains(ingId))) {
        validPlats.add(platId);
      }
    }
    
    return getPlatsByIds(validPlats);
  }

  List<Map<String, dynamic>> getPlatsByIngredientsOnly(List<int> ingredientIds) {
    if (ingredientIds.isEmpty) return [];
    
    // Trouver les plats où TOUS les ingrédients sont dans la liste
    final Set<int> availableIngredients = ingredientIds.toSet();
    
    final validPlats = <int>[];
    
    for (var plat in plats) {
      final platId = plat['plat_id'] as int;
      // Récupérer tous les ingrédients de ce plat
      final platIngs = platIngredients
          .where((pi) => pi['plat_id'] == platId)
          .map((pi) => pi['ingredient_id'] as int)
          .toSet();
      
      // Vérifier si tous les ingrédients du plat sont disponibles
      if (platIngs.every((ingId) => availableIngredients.contains(ingId))) {
        validPlats.add(platId);
      }
    }
    
    return getPlatsByIds(validPlats);
  }
}
