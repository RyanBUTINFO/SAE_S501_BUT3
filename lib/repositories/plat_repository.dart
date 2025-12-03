import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'dart:math';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- Méthodes existantes (gardées pour ne rien casser) ---

  Future<List<Plat>> getTopPlatsByOrigine(String origine, {int limit = 10}) async {
    if (kIsWeb) {
      return []; // Simplifié pour le contexte Web
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
      plat.image = plat.imagePath;
      plat.title = plat.nom;
      plat.level = plat.type;
      plat.context = plat.instructions; // corrigé ici
      return plat;
    }).toList();
  }

  // --- NOUVELLE MÉTHODE DE RECHERCHE AVANCÉE ---

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

    // 1. Recherche textuelle
    if (query.isNotEmpty) {
      finalWhereClause += ' AND lower(nom) LIKE ?';
      finalWhereArgs.add('%${query.toLowerCase()}%');
    }

    // 2. Filtre difficulté
    if (difficulties.isNotEmpty) {
      final placeholders = List.filled(difficulties.length, 'lower(?)').join(',');
      finalWhereClause += " AND lower(type) IN ($placeholders)";
      finalWhereArgs.addAll(difficulties.map((e) => e.toLowerCase()));
    }

    // 3. Filtre mode de cuisson
    if (cookingModes.isNotEmpty) {
      List<String> conditions = [];
      for (var mode in cookingModes) {
        conditions.add("lower(methodes_cuisson) LIKE ?"); // corrigé ici
        finalWhereArgs.add('%${mode.toLowerCase()}%');
      }
      if (conditions.isNotEmpty) {
        finalWhereClause += " AND (${conditions.join(' OR ')})";
      }
    }

    // 4. Filtre ingrédients
    if (ingredients.isNotEmpty) {
      List<String> conditions = [];
      for (var ing in ingredients) {
        conditions.add("lower(instructions) LIKE ?"); // corrigé ici
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
        plat.context = plat.instructions; // corrigé ici
        return plat;
      }).toList();
    } catch (e) {
      print("Erreur SQL: $e");
      return [];
    }
  }
}
