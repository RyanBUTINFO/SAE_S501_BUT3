import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String dbPath = join(await getDatabasesPath(), "base_miaam.db");
    
    if (!(await databaseExists(dbPath))) {
      ByteData data = await rootBundle.load("assets/database/base_miaam.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    // On ouvre la base et on s'assure que la table des favoris existe
    return await openDatabase(
      dbPath,
      version: 1,
      onOpen: (db) async {
        // Cette table stocke les IDs des plats aimés. 
        // C'est le point de départ de l'évolution de l'algo.
        await db.execute('''
          CREATE TABLE IF NOT EXISTS favoris (
            plat_id INTEGER PRIMARY KEY
          )
        ''');
      },
    );
  }

  // --- NOUVELLES MÉTHODES POUR LES FAVORIS ---

  Future<int> addFavori(int platId) async {
    final db = await database;
    return await db.insert(
      'favoris', 
      {'plat_id': platId},
      conflictAlgorithm: ConflictAlgorithm.replace, // Évite les doublons
    );
  }

  Future<int> removeFavori(int platId) async {
    final db = await database;
    return await db.delete('favoris', where: 'plat_id = ?', whereArgs: [platId]);
  }

  Future<List<int>> getFavorisIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favoris');
    return maps.map((e) => e['plat_id'] as int).toList();
  }

  // --- TES MÉTHODES EXISTANTES (GARDÉES INTACTES) ---

  Future<List<Map<String, dynamic>>> getAllPlats() async {
    final db = await database;
    return await db.query('plats'); 
  }

  Future<List<Map<String, dynamic>>> getIngredientsForPlat(int platId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT i.nom, pi.quantite, pi.unite
      FROM Plat_ingredient pi
      JOIN Ingredient i ON pi.ingredient_id = i.id
      WHERE pi.plat_id = ?
    ''', [platId]);
  }

  Future<List<Map<String, dynamic>>> searchPlatsByName(String query) async {
    final db = await database;
    return await db.query(
      'plats',
      where: 'nom LIKE ?',
      whereArgs: ['%$query%'],
    );
  }
}