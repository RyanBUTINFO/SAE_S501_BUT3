import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/in_memory_db.dart';
import '../models/plat.dart';
import '../models/ingredient_recette.dart';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- 1. RÉCUPÉRATION CLASSIQUE (Home & Recommandations) ---
  Future<List<Plat>> getAllPlatsWithVectors() async {
    final db = await _dbHelper.database;
    
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*, v.* FROM plats p 
        INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
      ''');
      
      return maps.map((row) {
        Plat p = Plat.fromMap(row);
        
        // ⚡ Vérification de sécurité pour les vecteurs
        try {
          p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
        } catch (e) {
          if (kDebugMode) print("⚠️ Vecteur manquant pour ${p.nom}");
          p.vector = [];
        }
        
        return p;
      }).toList();
    } catch (e) {
      if (kDebugMode) print("❌ Erreur getAllPlatsWithVectors: $e");
      return [];
    }
  }

  // --- 2. RÉCUPÉRATION PAR IDS (Utilisé pour afficher la liste des favoris) ---
  Future<List<Plat>> getPlatsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await _dbHelper.database;
    final String idString = ids.join(',');
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM plats WHERE plat_id IN ($idString)'
    );
    return maps.map((e) => Plat.fromMap(e)).toList();
  }

  // --- 3. RECHERCHE FRIGO (Au moins certains ingrédients) ---
  Future<List<Plat>> getPlatsByIngredients(List<int> ingredientIds) async {
    if (ingredientIds.isEmpty) return [];
    
    if (kIsWeb) {
      // 🌐 Sur le web, utiliser la BD en mémoire (travail de Kevin)
      try {
        await InMemoryDatabase().init();
        final platMaps = InMemoryDatabase().getPlatsByIngredients(ingredientIds);
        return platMaps.map((e) => Plat.fromMap(e)).toList();
      } catch (e) {
        if (kDebugMode) print('Erreur getPlatsByIngredients (web): $e');
        return [];
      }
    } else {
      // 📱 Sur mobile/desktop, utiliser sqflite
      final db = await _dbHelper.database;
      final String ids = ingredientIds.join(',');
      
      try {
        final List<Map<String, dynamic>> res = await db.rawQuery('''
          SELECT p.*, v.*, COUNT(pi.ingredient_id) as score_frigo
          FROM plats p
          INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
          INNER JOIN Plat_ingredient pi ON p.plat_id = pi.plat_id
          WHERE pi.ingredient_id IN ($ids)
          GROUP BY p.plat_id
          ORDER BY score_frigo DESC
          LIMIT 50
        ''');
        
        return res.map((row) {
          Plat p = Plat.fromMap(row);
          try {
            p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
          } catch (e) {
            if (kDebugMode) print("⚠️ Vecteur manquant pour ${p.nom}");
            p.vector = [];
          }
          return p;
        }).toList();
      } catch (e) {
        if (kDebugMode) print("❌ Erreur getPlatsByIngredients: $e");
        return [];
      }
    }
  }

  // --- 3b. RECHERCHE FRIGO (Seulement plats faisables) - Ajout de Kevin ---
  Future<List<Plat>> getPlatsByIngredientsOnly(List<int> ingredientIds) async {
    if (ingredientIds.isEmpty) return [];
    
    if (kIsWeb) {
      // 🌐 Sur le web
      try {
        await InMemoryDatabase().init();
        final platMaps = InMemoryDatabase().getPlatsByIngredientsOnly(ingredientIds);
        return platMaps.map((e) => Plat.fromMap(e)).toList();
      } catch (e) {
        if (kDebugMode) print('Erreur getPlatsByIngredientsOnly (web): $e');
        return [];
      }
    } else {
      // 📱 Sur mobile/desktop
      final db = await _dbHelper.database;
      final String ids = ingredientIds.join(',');
      
      try {
        final List<Map<String, dynamic>> res = await db.rawQuery('''
          SELECT p.*, v.*
          FROM plats p
          INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
          WHERE NOT EXISTS (
            SELECT 1 FROM Plat_ingredient pi
            WHERE pi.plat_id = p.plat_id
            AND pi.ingredient_id NOT IN ($ids)
          )
          LIMIT 50
        ''');
        
        return res.map((row) {
          Plat p = Plat.fromMap(row);
          try {
            p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
          } catch (e) {
            if (kDebugMode) print("⚠️ Vecteur manquant pour ${p.nom}");
            p.vector = [];
          }
          return p;
        }).toList();
      } catch (e) {
        if (kDebugMode) print("❌ Erreur getPlatsByIngredientsOnly: $e");
        return [];
      }
    }
  }

  // --- 4. RECHERCHE CLASSIQUE ---
  Future<List<Plat>> search(String query, List<String> diffs) async {
    final db = await _dbHelper.database;
    String whereClause = "nom LIKE ?";
    List<dynamic> args = ["%$query%"];
    
    if (diffs.isNotEmpty) {
      String placeholders = List.filled(diffs.length, '?').join(',');
      whereClause += " AND type IN ($placeholders)";
      args.addAll(diffs);
    }
    
    final res = await db.query('plats', where: whereClause, whereArgs: args, limit: 50);
    return res.map((e) => Plat.fromMap(e)).toList();
  }

  // --- 5. SUGGESTIONS INGRÉDIENTS ---
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    if (query.length < 1) return [];
    
    if (kIsWeb) {
      // 🌐 Sur le web (travail de Kevin)
      try {
        await InMemoryDatabase().init();
        return InMemoryDatabase().searchIngredients(query);
      } catch (e) {
        if (kDebugMode) print('Erreur searchIngredients (web): $e');
        return [];
      }
    } else {
      // 📱 Sur mobile/desktop
      final db = await _dbHelper.database;
      
      try {
        // Essayer avec la table "ingredients" (minuscules)
        List<Map<String, dynamic>> results = await db.rawQuery(
          'SELECT id, nom FROM ingredients WHERE nom LIKE ? COLLATE NOCASE LIMIT 20',
          ['%$query%']
        );
        
        if (results.isEmpty) {
          // Fallback : essayer avec "Ingredient" (majuscule)
          results = await db.rawQuery(
            'SELECT id, nom FROM Ingredient WHERE nom LIKE ? COLLATE NOCASE LIMIT 20',
            ['%$query%']
          );
        }
        
        return results;
      } catch (e) {
        if (kDebugMode) print('Erreur searchIngredients: $e');
        return [];
      }
    }
  }

  Future<void> hydraterIngredients(Plat plat) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT i.nom, pi.quantite, pi.unite
      FROM Plat_ingredient pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.plat_id = ?
    ''', [plat.id]);
    plat.ingredients = res.map((m) => IngredientRecette.fromMap(m)).toList();
  }

  // =========================================================
  // --- MÉTHODES POUR L'ALGO (Notre travail) ---
  // =========================================================

  Future<void> toggleFavori(int platId, bool isAdding) async {
    if (isAdding) {
      await _dbHelper.addFavori(platId);
    } else {
      await _dbHelper.removeFavori(platId);
    }
  }

  Future<List<int>> getFavorisIds() async {
    return await _dbHelper.getFavorisIds();
  }

  // ⚡ VERSION AMÉLIORÉE avec debug
  Future<List<Plat>> getFavorisWithVectors() async {
    final List<int> ids = await getFavorisIds();
    if (ids.isEmpty) return [];

    final db = await _dbHelper.database;
    final String idString = ids.join(',');

    if (kDebugMode) print("🔍 Chargement des favoris (IDs: $idString)");

    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*, v.* FROM plats p 
        INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
        WHERE p.plat_id IN ($idString)
      ''');

      if (maps.isEmpty) {
        if (kDebugMode) print("⚠️ Aucun plat trouvé avec ces IDs !");
        return [];
      }

      return maps.map((row) {
        Plat p = Plat.fromMap(row);
        
        try {
          p.vector = List.generate(27, (j) {
            final val = row['v$j'];
            if (val == null) throw Exception("Colonne v$j est null");
            return (val as num).toDouble();
          });
          
          if (kDebugMode) {
            print("   ✅ ${p.nom} → Vecteur OK (${p.vector.take(3).toList()}...)");
          }
        } catch (e) {
          if (kDebugMode) {
            print("   ❌ ${p.nom} → VECTEUR MANQUANT !");
            print("      Erreur : $e");
          }
          p.vector = [];
        }
        
        return p;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ ERREUR SQL dans getFavorisWithVectors : $e");
        print("   → La table 'plat_vectors' existe-t-elle ?");
      }
      return [];
    }
  }
  
  Future<Plat?> getPlatById(int id) async {
    final db = await _dbHelper.database; 

    final List<Map<String, dynamic>> maps = await db.query(
      'plats',
      where: 'plat_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plat.fromMap(maps.first);
    }
    return null;
  }

  // --- 6. FILTRAGE (Pour les allergies/exclusions) ---
  Future<Set<int>> getPlatIdsWithIngredients(List<String> ingredientsList) async {
    if (ingredientsList.isEmpty) return {};
    
    final db = await _dbHelper.database;
    final Set<int> forbiddenIds = {};

    for (String ing in ingredientsList) {
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT DISTINCT pi.plat_id 
        FROM Plat_ingredient pi
        JOIN ingredients i ON pi.ingredient_id = i.id
        WHERE i.nom LIKE ?
      ''', ['%$ing%']); 
      
      forbiddenIds.addAll(maps.map((e) => e['plat_id'] as int));
    }
    return forbiddenIds;
  }
}
