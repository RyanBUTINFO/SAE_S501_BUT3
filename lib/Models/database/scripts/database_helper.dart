import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart'; // <-- IMPORTANT

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _sqfliteDb; // SQLite mobile/desktop
  Database? _sembastDb;          // Sembast web

  Future<void> initDatabase() async {
    if (kIsWeb) {
      // Web : Sembast Web persistant (IndexedDB)
      final dbFactory = databaseFactoryWeb;
      _sembastDb = await dbFactory.openDatabase('miaam_web.db');
      print('Base web (Sembast Web) initialisée');
    } else {
      // Mobile / Desktop : SQLite
      if (_sqfliteDb != null) return;

      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, 'base_miaam.db');

      _sqfliteDb = await sqflite.openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE plats (
              id INTEGER PRIMARY KEY,
              nom TEXT NOT NULL,
              type TEXT,
              cuisine TEXT,
              origine TEXT,
              temps_preparation REAL,
              temps_cuisson REAL,
              nb_personnes INTEGER,
              nombre_etapes INTEGER,
              instructions TEXT,
              methodes_cuisson TEXT,
              ustensiles TEXT,
              image_path TEXT,
              calories TEXT,
              valeur_nutritionnelle TEXT,
              empreinte_carbone REAL
            );
          ''');

          await db.execute('''
            CREATE TABLE ingredients (
              id INTEGER PRIMARY KEY,
              nom TEXT NOT NULL UNIQUE
            );
          ''');

          await db.execute('''
            CREATE TABLE plat_ingredient (
              plat_id INTEGER NOT NULL,
              ingredient_id INTEGER NOT NULL,
              quantite REAL,
              unite TEXT,
              PRIMARY KEY (plat_id, ingredient_id),
              FOREIGN KEY (plat_id) REFERENCES plats(id),
              FOREIGN KEY (ingredient_id) REFERENCES ingredients(id)
            );
          ''');
        },
      );
      print('Base mobile/desktop (SQLite) initialisée');
    }
  }

  // Getters
  sqflite.Database? get sqfliteDb => _sqfliteDb;
  Database? get sembastDb => _sembastDb;
}
