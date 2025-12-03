import 'dart:io' show File, Directory;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import 'package:sembast_web/sembast_web.dart';

class DatabaseHelper {
  // Singleton Pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Instances de bases de données
  sqflite.Database? _sqfliteDb;
  Database? _sembastDb;

  // Getters
  sqflite.Database? get sqfliteDb => _sqfliteDb;
  Database? get sembastDb => _sembastDb;

  // Constantes
  static const String _dbAssetPath = 'assets/database/base_miaam.db';
  static const String _dbName = 'base_miaam.db';
  static const String _webDbName = 'miaam_web.db';

  /// Initialise la base de données selon la plateforme
  Future<void> initDatabase() async {
    try {
      if (kIsWeb) {
        await _initWebDatabase();
      } else {
        await _initMobileDatabase();
      }
    } catch (e) {
      debugPrint("ERREUR CRITIQUE lors de l'initialisation de la BDD : $e");
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIQUE WEB (Sembast)
  // ---------------------------------------------------------------------------
  
  Future<void> _initWebDatabase() async {
    final dbFactory = databaseFactoryWeb;
    _sembastDb = await dbFactory.openDatabase(_webDbName);
    debugPrint('🌐 Base Web (Sembast) initialisée avec succès.');
  }

  // ---------------------------------------------------------------------------
  // LOGIQUE MOBILE / DESKTOP (SQLite)
  // ---------------------------------------------------------------------------

  Future<void> _initMobileDatabase() async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Vérification et copie depuis les assets si nécessaire
    final exists = await File(path).exists();

    if (!exists) {
      debugPrint('📂 BDD introuvable. Copie depuis les assets...');
      await _copyDatabaseFromAssets(path);
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

    // Ouverture de la base SQLite
    _sqfliteDb = await sqflite.openDatabase(
      path,
      version: 1,
      onOpen: (db) => debugPrint('📱 Base Mobile (SQLite) ouverte.'),
    );
  }

  /// Helper pour copier le fichier .db des assets vers le stockage local
  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      // Création du répertoire parent
      await Directory(dirname(path)).create(recursive: true);

      // Chargement et écriture des données
      final data = await rootBundle.load(_dbAssetPath);
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      await File(path).writeAsBytes(bytes, flush: true);
      debugPrint('📥 Copie de la BDD réussie !');
    } catch (e) {
      debugPrint("⚠️ Erreur lors de la copie de l'asset : $e");
      // On relance l'erreur pour qu'elle soit attrapée par initDatabase
      throw Exception("Impossible de copier la DB depuis les assets");
    }
  }

  // ---------------------------------------------------------------------------
  // MÉTHODES DE RÉCUPÉRATION (Unifiées)
  // ---------------------------------------------------------------------------

  /// Récupère tous les plats (Compatible Web & Mobile)
  Future<List<Map<String, dynamic>>> getAllPlats() async {
    if (kIsWeb) {
      // Sembast : Lecture depuis le store 'plats'
      if (_sembastDb == null) return [];
      
      final store = intMapStoreFactory.store('plats');
      final snapshots = await store.find(_sembastDb!);
      
      // Conversion du format Sembast vers une Map standard
      return snapshots.map((record) => record.value).toList();
    } else {
      // SQLite : Requête SQL standard
      final db = _sqfliteDb;
      if (db == null) return [];
      
      return await db.query('plats');
    }
  }
}