import '../database/database_helper.dart';
import '../models/plat.dart';
import '../models/ingredient_recette.dart';
import 'package:flutter/foundation.dart';

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
        
        // ⚠️ VÉRIFICATION : Est-ce que les colonnes v0...v26 existent ?
        try {
          p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
        } catch (e) {
          debugPrint("❌ ERREUR : Impossible de lire le vecteur pour ${p.nom} (ID: ${p.id})");
          debugPrint("   Colonnes disponibles : ${row.keys.toList()}");
          p.vector = []; // Vecteur vide par défaut
        }
        
        return p;
      }).toList();
    } catch (e) {
      debugPrint("❌ ERREUR SQL dans getAllPlatsWithVectors : $e");
      debugPrint("   → Vérifie que la table 'plat_vectors' existe dans la base de données");
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

  // --- 3. RECHERCHE FRIGO ---
  Future<List<Plat>> getPlatsByIngredients(List<int> ingredientIds) async {
    if (ingredientIds.isEmpty) return [];
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
          debugPrint("⚠️ Vecteur manquant pour ${p.nom}");
          p.vector = [];
        }
        return p;
      }).toList();
    } catch (e) {
      debugPrint("❌ ERREUR dans getPlatsByIngredients : $e");
      return [];
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
    if (query.length < 2) return [];
    final db = await _dbHelper.database;
    return await db.query('Ingredient', where: 'nom LIKE ?', whereArgs: ['%$query%'], limit: 20);
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
  // --- MÉTHODES POUR L'ÉVOLUTION DE L'ALGO ---
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

  // ⚡ VERSION CORRIGÉE AVEC DEBUG
  Future<List<Plat>> getFavorisWithVectors() async {
    final List<int> ids = await getFavorisIds();
    if (ids.isEmpty) return [];

    final db = await _dbHelper.database;
    final String idString = ids.join(',');

    debugPrint("🔍 Chargement des favoris (IDs: $idString)");

    try {
      // On joint la table plats et plat_vectors pour avoir les 27 dimensions
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.*, v.* FROM plats p 
        INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
        WHERE p.plat_id IN ($idString)
      ''');

      if (maps.isEmpty) {
        debugPrint("⚠️ Aucun plat trouvé avec ces IDs !");
        return [];
      }

      return maps.map((row) {
        Plat p = Plat.fromMap(row);
        
        // ⚡ VÉRIFICATION CRITIQUE : Le vecteur est-il présent ?
        try {
          p.vector = List.generate(27, (j) {
            final val = row['v$j'];
            if (val == null) {
              throw Exception("Colonne v$j est null");
            }
            return (val as num).toDouble();
          });
          
          debugPrint("   ✅ ${p.nom} → Vecteur OK (${p.vector.take(3).toList()}...)");
        } catch (e) {
          debugPrint("   ❌ ${p.nom} → VECTEUR MANQUANT !");
          debugPrint("      Erreur : $e");
          debugPrint("      Colonnes : ${row.keys.take(10).toList()}...");
          p.vector = [];
        }
        
        return p;
      }).toList();
    } catch (e) {
      debugPrint("❌ ERREUR SQL dans getFavorisWithVectors : $e");
      debugPrint("   → La table 'plat_vectors' existe-t-elle ?");
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
