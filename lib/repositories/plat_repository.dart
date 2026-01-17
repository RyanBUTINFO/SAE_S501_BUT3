import '../database/database_helper.dart';
import '../models/plat.dart';
import '../models/ingredient_recette.dart';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- 1. RÉCUPÉRATION CLASSIQUE (Home & Recommandations) ---
  Future<List<Plat>> getAllPlatsWithVectors() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, v.* FROM plats p 
      INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
    ''');
    return maps.map((row) {
      Plat p = Plat.fromMap(row);
      p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
      return p;
    }).toList();
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
      p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
      return p;
    }).toList();
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
  // --- NOUVELLES MÉTHODES POUR L'ÉVOLUTION DE L'ALGO ---
  // =========================================================

  // Étape A : Ajouter/Retirer via le Helper
  Future<void> toggleFavori(int platId, bool isAdding) async {
    if (isAdding) {
      await _dbHelper.addFavori(platId);
    } else {
      await _dbHelper.removeFavori(platId);
    }
  }

  // Étape B : Récupérer les IDs pour savoir ce que l'user aime
  Future<List<int>> getFavorisIds() async {
    return await _dbHelper.getFavorisIds();
  }

  // Étape C : CRUCIAL POUR L'ALGO - Récupérer les plats favoris AVEC leurs vecteurs
  Future<List<Plat>> getFavorisWithVectors() async {
    final List<int> ids = await getFavorisIds();
    if (ids.isEmpty) return [];

    final db = await _dbHelper.database;
    final String idString = ids.join(',');

    // On joint la table plats et plat_vectors pour avoir les 27 dimensions
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, v.* FROM plats p 
      INNER JOIN plat_vectors v ON p.plat_id = v.plat_id
      WHERE p.plat_id IN ($idString)
    ''');

    return maps.map((row) {
      Plat p = Plat.fromMap(row);
      p.vector = List.generate(27, (j) => (row['v$j'] as num).toDouble());
      return p;
    }).toList();
  }
  
  Future<Plat?> getPlatById(int id) async {
    // On utilise _dbHelper comme dans tes autres méthodes
    final db = await _dbHelper.database; 

    final List<Map<String, dynamic>> maps = await db.query(
      'plats',
      where: 'plat_id = ?', // Correction : c'est plat_id dans ton SQL
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Plat.fromMap(maps.first); // Utilise fromMap comme les autres
    }
    return null;
  }
  
}