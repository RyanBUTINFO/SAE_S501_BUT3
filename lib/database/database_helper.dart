import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:csv/csv.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _sqfliteDb; 
  Database? _sembastDb;          

  sqflite.Database? get sqfliteDb => _sqfliteDb;
  Database? get sembastDb => _sembastDb;

  Future<void> initDatabase() async {
    if (kIsWeb) {
      final dbFactory = databaseFactoryWeb;
      _sembastDb = await dbFactory.openDatabase('miaam_web.db');
      print('Base web (Sembast Web) initialisée');
    } else {
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

    await importCsvToDb();
  }

  // ----------------------------
  // Charge CSV depuis assets
  // ----------------------------
  Future<List<Map<String, dynamic>>> loadCsv(String path) async {
    final csvString = await rootBundle.loadString(path);
    final csvRows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    final headers = csvRows.first.map((e) => e.toString()).toList();
    final dataRows = csvRows.sublist(1);

    return dataRows.map((row) {
      final Map<String, dynamic> map = {}; // <-- dynamic pour pouvoir stocker double/int
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i].toString();
      }
      return map;
    }).toList();
  }

  Future<void> importCsvToDb() async {
    if (kIsWeb) {
      await _importCsvWeb();
    } else {
      await _importCsvMobile();
    }
  }

  // -----------------------------
  // Mobile/Desktop : SQLite transaction + batch
  // -----------------------------
  Future<void> _importCsvMobile() async {
    final db = _sqfliteDb;
    if (db == null) return;

    final plats = await loadCsv('assets/Csv_database/plats.csv');
    final ingredients = await loadCsv('assets/Csv_database/ingredients.csv');
    final platIngredients = await loadCsv('assets/Csv_database/plat_ingredient.csv');

    await db.transaction((txn) async {
      // Plats
      var platsBatch = txn.batch();
      for (var plat in plats) {
        plat['temps_preparation'] = plat['temps_preparation'] != null ? double.tryParse(plat['temps_preparation']!) : null;
        plat['temps_cuisson'] = plat['temps_cuisson'] != null ? double.tryParse(plat['temps_cuisson']!) : null;
        plat['nb_personnes'] = plat['nb_personnes'] != null ? int.tryParse(plat['nb_personnes']!) : null;
        plat['nombre_etapes'] = plat['nombre_etapes'] != null ? int.tryParse(plat['nombre_etapes']!) : null;
        plat['empreinte_carbone'] = plat['empreinte_carbone'] != null ? double.tryParse(plat['empreinte_carbone']!) : null;

        plat['methodes_cuisson'] = plat['methodes_cuisson'] != null ? jsonEncode(plat['methodes_cuisson']) : '[]';
        plat['ustensiles'] = plat['ustensiles'] != null ? jsonEncode(plat['ustensiles']) : '[]';

        platsBatch.insert('plats', plat, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
      }
      await platsBatch.commit(noResult: true);

      // Ingredients
      var ingBatch = txn.batch();
      for (var ing in ingredients) {
        ingBatch.insert('ingredients', ing, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
      }
      await ingBatch.commit(noResult: true);

      // Plat_Ingredient
      var piBatch = txn.batch();
      for (var pi in platIngredients) {
        pi['quantite'] = pi['quantite'] != null ? double.tryParse(pi['quantite']!) : null;
        piBatch.insert('plat_ingredient', pi, conflictAlgorithm: sqflite.ConflictAlgorithm.replace);
      }
      await piBatch.commit(noResult: true);

      // Confirmation
      final countPlatsResult = await txn.rawQuery('SELECT COUNT(*) as c FROM plats');
      final countPlats = countPlatsResult.first['c'];

      final countIngResult = await txn.rawQuery('SELECT COUNT(*) as c FROM ingredients');
      final countIng = countIngResult.first['c'];

      final countPIResult = await txn.rawQuery('SELECT COUNT(*) as c FROM plat_ingredient');
      final countPI = countPIResult.first['c'];

      print('CSV importés (Mobile/Desktop) : plats=$countPlats, ingredients=$countIng, plat_ingredient=$countPI');

    });
  }

  // -----------------------------
  // Web : Sembast transaction
  // -----------------------------
  Future<void> _importCsvWeb() async {
    final db = _sembastDb;
    if (db == null) return;

    final platsStore = intMapStoreFactory.store('plats');
    final ingredientsStore = intMapStoreFactory.store('ingredients');
    final platIngredientStore = intMapStoreFactory.store('plat_ingredient');

    final plats = await loadCsv('assets/Csv_database/plats.csv');
    final ingredients = await loadCsv('assets/Csv_database/ingredients.csv');
    final platIngredients = await loadCsv('assets/Csv_database/plat_ingredient.csv');

    await db.transaction((txn) async {
      for (var plat in plats) {
        plat['temps_preparation'] = plat['temps_preparation'] != null ? double.tryParse(plat['temps_preparation']!) : null;
        plat['temps_cuisson'] = plat['temps_cuisson'] != null ? double.tryParse(plat['temps_cuisson']!) : null;
        plat['nb_personnes'] = plat['nb_personnes'] != null ? int.tryParse(plat['nb_personnes']!) : null;
        plat['nombre_etapes'] = plat['nombre_etapes'] != null ? int.tryParse(plat['nombre_etapes']!) : null;
        plat['empreinte_carbone'] = plat['empreinte_carbone'] != null ? double.tryParse(plat['empreinte_carbone']!) : null;

        plat['methodes_cuisson'] = plat['methodes_cuisson'] != null ? jsonEncode(plat['methodes_cuisson']) : '[]';
        plat['ustensiles'] = plat['ustensiles'] != null ? jsonEncode(plat['ustensiles']) : '[]';

        await platsStore.add(txn, plat);
      }

      for (var ing in ingredients) {
        await ingredientsStore.add(txn, ing);
      }

      for (var pi in platIngredients) {
        pi['quantite'] = pi['quantite'] != null ? double.tryParse(pi['quantite']!) : null;
        await platIngredientStore.add(txn, pi);
      }

      // Confirmation Web
      final countPlats = await platsStore.count(txn);
      final countIng = await ingredientsStore.count(txn);
      final countPI = await platIngredientStore.count(txn);
      print('CSV importés (Web) : plats=$countPlats, ingredients=$countIng, plat_ingredient=$countPI');
    });
  }
}
