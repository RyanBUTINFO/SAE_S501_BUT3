import '../database/database_helper.dart';
import '../models/plat.dart';
import '../models/ingredient_recette.dart'; // Import pour le modèle enrichi
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:convert'; // Import pour jsonDecode
//import 'package:sembast/sembast/database.dart'; 
import 'dart:math';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- Méthodes existantes ---

  Future<List<Plat>> getTopPlatsByOrigine(String origine, {int limit = 10}) async {
    if (kIsWeb) {
      return [];
    } else {
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query(
        'plats',
        where: 'origine LIKE ?',
        whereArgs: ['%$origine%'],
        limit: limit,
      );
      return result.map((e) => Plat.fromMap(e)).toList();
    }
  }

  Future<List<Plat>> getRandomPlats({int limit = 10}) async {
    final db = _dbHelper.sqfliteDb;
    if (db == null) return [];

    final result = await db.query('plats');
    final random = Random();
    final shuffled = List.of(result)..shuffle(random);

    return shuffled.take(limit).map((e) {
      final plat = Plat.fromMap(e);
      // Alias existants
      plat.image = plat.imagePath;
      plat.title = plat.nom;
      plat.level = plat.type;
      plat.context = plat.instructions;
      return plat;
    }).toList();
  }

  Future<List<Plat>> searchPlatsByCriteria({
    required String query,
    List<String> difficulties = const [],
    List<String> ingredients = const [],
    List<String> cookingModes = const [],
    int limit = 50,
  }) async {
    final db = _dbHelper.sqfliteDb;
    if (db == null) return [];

    String finalWhereClause = '1=1';
    List<dynamic> finalWhereArgs = [];

    // Logique de recherche : Recherche textuelle
    if (query.isNotEmpty) {
      finalWhereClause += ' AND lower(nom) LIKE ?';
      finalWhereArgs.add('%${query.toLowerCase()}%');
    }

    // Logique de recherche : Filtre difficulté
    if (difficulties.isNotEmpty) {
      final placeholders = List.filled(difficulties.length, 'lower(?)').join(',');
      finalWhereClause += " AND lower(type) IN ($placeholders)";
      finalWhereArgs.addAll(difficulties.map((e) => e.toLowerCase()));
    }

    // Logique de recherche : Filtre mode de cuisson
    if (cookingModes.isNotEmpty) {
      List<String> conditions = [];
      for (var mode in cookingModes) {
        conditions.add("lower(methodes_cuisson) LIKE ?");
        finalWhereArgs.add('%${mode.toLowerCase()}%');
      }
      if (conditions.isNotEmpty) {
        finalWhereClause += " AND (${conditions.join(' OR ')})";
      }
    }

    // Logique de recherche : Filtre ingrédients (basé sur instructions/description)
    if (ingredients.isNotEmpty) {
      List<String> conditions = [];
      for (var ing in ingredients) {
        conditions.add("lower(instructions) LIKE ?");
        finalWhereArgs.add('%${ing.toLowerCase()}%');
      }
      if (conditions.isNotEmpty) {
        finalWhereClause += " AND (${conditions.join(' OR ')})";
      }
    }

    // Exécution de la requête
    try {
      final result = await db.query(
        'plats',
        where: finalWhereClause,
        whereArgs: finalWhereArgs,
        limit: limit,
      );

      return result.map((e) {
        final plat = Plat.fromMap(e);
        plat.image = plat.imagePath;
        plat.title = plat.nom;
        plat.level = plat.type;
        plat.context = plat.instructions;
        return plat;
      }).toList();
    } catch (e) {
      debugPrint("Erreur SQL: $e");
      return [];
    }
  }

  // ----------------------------------------------------------------------
  // --- NOUVELLE LOGIQUE POUR LA PAGE DE DÉTAILS (RecipePage) ---
  // ----------------------------------------------------------------------


  /// [NOUVEAU] Récupère la liste complète des ingrédients enrichis pour un plat donné
  Future<List<IngredientRecette>> _getIngredientsForPlat(int platId) async {
    final db = _dbHelper.sqfliteDb;
    if (db == null) return [];

    // Requête SQL de Jointure : Plat_ingredient (T1) avec Ingredient (T2)
    const String sql = '''
      SELECT 
        T2.nom, 
        T1.quantite, 
        T1.unite 
      FROM Plat_ingredient T1
      INNER JOIN Ingredient T2 ON T1.ingredient_id = T2.id
      WHERE T1.plat_id = ?;
    ''';

    try {
      final List<Map<String, dynamic>> result = await db.rawQuery(
        sql,
        [platId],
      );

      // Utilise le factory IngredientRecette.fromMap
      return result.map((map) => IngredientRecette.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des ingrédients : $e");
      return [];
    }
  }


  /// [NOUVEAU] Prend un objet Plat de base et l'enrichit avec toutes les données complexes 
  /// requises par la RecipePage (ingrédients, décodage JSON).
  Future<Plat> enrichirPlatPourDetails(Plat plat) async {
    // 1. Hydratation des ingrédients
    if (plat.id != null) {
      plat.ingredientsRecette = await _getIngredientsForPlat(plat.id!);
    }
    
    // 2. Décoder le JSON pour les ustensiles (si la vue les utilise en liste)
    if (plat.ustensiles != null && plat.ustensiles!.isNotEmpty) {
      try {
        final List<dynamic> ustensilesList = jsonDecode(plat.ustensiles!);
        // Le décodage est fait, mais la valeur reste dans la propriété String pour l'instant
      } catch (e) {
        debugPrint("Erreur de décodage JSON des ustensiles: $e");
      }
    }

    // 3. Décoder le JSON pour les valeurs nutritionnelles
    if (plat.valeurNutritionnelle != null && plat.valeurNutritionnelle!.isNotEmpty) {
      try {
        final Map<String, dynamic> nutritionalMap = jsonDecode(plat.valeurNutritionnelle!);
      } catch (e) {
        debugPrint("Erreur de décodage JSON nutritionnel: $e");
      }
    }

    // L'objet Plat est maintenant enrichi et prêt pour la RecipePage
    return plat;
  }
}