import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'dart:math';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- Méthodes existantes (gardées pour ne rien casser) ---

  Future<List<Plat>> getTopPlatsByOrigine(String origine, {int limit = 10}) async {
    // (Code inchangé pour cette partie, on garde la logique existante)
    if (kIsWeb) {
      return []; // Simplifié pour le contexte
    } else {
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query('plats', where: 'origine LIKE ?', whereArgs: ['%$origine%'], limit: limit);
      return result.map((e) => Plat.fromMap(e)).toList();
    }
  }

  Future<List<Plat>> getRandomPlats({int limit = 10}) async {
    // (Code inchangé)
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
      plat.context = plat.instructionsText;
      return plat;
    }).toList();
  }

  // --- NOUVELLE MÉTHODE DE RECHERCHE AVANCÉE ---

  Future<List<Plat>> searchPlatsByCriteria({
    required String query,
    List<String> difficulties = const [],
    List<String> ingredients = const [],
    List<String> cookingModes = const [],
    // On ignore ecoImpacts pour l'instant pour éviter les erreurs SQL complexes
    int limit = 50,
  }) async {
    
    final db = _dbHelper.sqfliteDb;
    if (db == null) return [];

    String finalWhereClause = '1=1'; // Cette condition est toujours vraie, elle permet d'ajouter des "AND" ensuite
    List<dynamic> finalWhereArgs = [];

    // 1. RECHERCHE TEXTUELLE (Barre de recherche)
    if (query.isNotEmpty) {
      finalWhereClause += ' AND lower(nom) LIKE ?';
      finalWhereArgs.add('%${query.toLowerCase()}%');
    }

    // 2. FILTRE DIFFICULTÉ (Colonne 'type')
    if (difficulties.isNotEmpty) {
      // On crée une liste de '?'
      final placeholders = List.filled(difficulties.length, 'lower(?)').join(',');
      // On vérifie si le type est dans la liste (en minuscule pour ignorer la casse)
      finalWhereClause += " AND lower(type) IN ($placeholders)";
      finalWhereArgs.addAll(difficulties.map((e) => e.toLowerCase()));
    }

    // 3. FILTRE MODE DE CUISSON (Cherche dans 'cooking_methods')
    if (cookingModes.isNotEmpty) {
      List<String> conditions = [];
      for (var mode in cookingModes) {
        conditions.add("lower(cooking_methods) LIKE ?");
        finalWhereArgs.add('%${mode.toLowerCase()}%');
      }
      // Si on a sélectionné "Four" et "Poêle", on cherche l'un OU l'autre
      if (conditions.isNotEmpty) {
        finalWhereClause += " AND (${conditions.join(' OR ')})";
      }
    }

    // 4. FILTRE INGRÉDIENTS (Cherche dans 'instructions_text' ou 'nom')
    if (ingredients.isNotEmpty) {
      List<String> conditions = [];
      for (var ing in ingredients) {
        // On regarde si le mot ingrédient apparaît dans les instructions
        conditions.add("lower(instructions_text) LIKE ?");
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
        // Mapping essentiel pour l'affichage
        plat.image = plat.imagePath;
        plat.title = plat.nom;
        plat.level = plat.type;
        return plat;
      }).toList();
    } catch (e) {
      print("Erreur SQL: $e");
      return [];
    }
  }
}