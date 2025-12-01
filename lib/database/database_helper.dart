import 'dart:io' show File, Directory;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sembast_web/sembast_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _sqfliteDb; 
  Database? _sembastDb; 
  
  sqflite.Database? get sqfliteDb => _sqfliteDb;
  Database? get sembastDb => _sembastDb;

  // Chemin vers la DB pré-remplie dans les assets
  static const String _dbAssetPath = 'assets/database/base_miaam.db';
  static const String _dbName = 'base_miaam.db';


  Future<void> initDatabase() async {
    if (kIsWeb) {
      // Logique pour le Web (Sembast)
      final dbFactory = databaseFactoryWeb;
      _sembastDb = await dbFactory.openDatabase('miaam_web.db');
      print('Base web (Sembast Web) initialisée');
    } else {
      // Logique pour Mobile/Desktop (SQLite)
      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, _dbName);
      
      // Vérifie si la DB existe déjà.
      final exists = await File(path).exists();
      
      if (!exists) {
        // --- LOGIQUE FINALE: Copie de l'asset si la DB n'existe pas ---
        print('Base de données non trouvée. Début de la copie rapide de l\'asset.');
        
        try {
          // 1. Lire l'asset (votre base de données pré-remplie)
          final data = await rootBundle.load(_dbAssetPath);
          
          // 2. Créer les répertoires si nécessaire
          await Directory(dirname(path)).create(recursive: true);
          
          // 3. Écrire l'asset dans le dossier des bases de données de l'application
          final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes, flush: true);

          print('Base de données $_dbName copiée avec succès de l\'asset. Prête à l\'emploi.');

        } catch (e) {
          print('ERREUR: Impossible de copier la base de données de l\'asset. Vérifiez le chemin et le fichier pubspec.yaml. $e');
        }
      } else {
        print('Base de données déjà existante. Ouverture directe.');
      }

      // Ouvre la base de données (que ce soit la nouvelle ou l'existante)
      _sqfliteDb = await sqflite.openDatabase(
        path,
        version: 1,
        onOpen: (db) {
          print('Base mobile/desktop (SQLite) ouverte. Lancement RAPIDE.');
        }
      );
    }
  }
  
  // -----------------------------
  // Méthode de Récupération de Données (Base)
  // -----------------------------
  Future<List<Map<String, dynamic>>> getAllPlats() async {
    if (kIsWeb) {
      // Logique de récupération Sembast (Web)
      return []; 
    } else {
      // Logique de récupération SQLite (Mobile/Desktop)
      final db = _sqfliteDb;
      if (db == null) return [];
      
      final List<Map<String, dynamic>> maps = await db.query('plats');
      
      return maps;
    }
  }
}