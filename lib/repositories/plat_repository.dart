import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'dart:math';


class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();


  /// Récupère les meilleurs plats selon l'origine
  Future<List<Plat>> getTopPlatsByOrigine(String origine, {int limit = 10}) async {
    if (kIsWeb) {
      final store = intMapStoreFactory.store('plats');
      final snapshot = await store.find(_dbHelper.sembastDb!);


      return snapshot
          .map((record) => Plat.fromMap(record.value))
          .where((plat) => 
              plat.origine != null && 
              plat.origine!.toLowerCase().contains(origine.toLowerCase()))
          .take(limit)
          .toList();
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


  /// Récupère des plats aléatoires
  Future<List<Plat>> getRandomPlats({int limit = 10}) async {
    if (kIsWeb) {
      // WEB: Sembast ne supporte pas le tri aléatoire natif, on mélange en mémoire
      final store = intMapStoreFactory.store('plats');
      final snapshot = await store.find(_dbHelper.sembastDb!);
      
      final random = Random();
      final shuffledSnapshot = List.of(snapshot)..shuffle(random);


      return shuffledSnapshot
          .take(limit)
          .map((record) => Plat.fromMap(record.value))
          .toList();
    } else {
      // MOBILE: Récupération et mélange en mémoire pour personnalisation
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query('plats');
      final random = Random();
      final shuffled = List.of(result)..shuffle(random);


      return shuffled.take(limit).map((e) {
        final plat = Plat.fromMap(e);


        // Création des attributs personnalisés
        plat.image = plat.imagePath;          // image
        plat.title = plat.nom;                  // title
        plat.level = plat.type;                 // level
        plat.context = plat.instructionsText;  // context

        return plat; // ← AJOUTÉ ICI
      }).toList();
    }
  }


  /// Recherche des plats par nom (contient le texte, insensible à la casse)
  Future<List<Plat>> searchPlatsByName(String query, {int limit = 10}) async {
    if (query.isEmpty) return [];


    final lowerQuery = query.toLowerCase();


    if (kIsWeb) {
      final store = intMapStoreFactory.store('plats');
      final snapshot = await store.find(_dbHelper.sembastDb!);


      return snapshot
          .map((record) => Plat.fromMap(record.value))
          .where((plat) {
            final nom = plat.nom ?? "";
            return nom.toLowerCase().contains(lowerQuery);
          })
          .take(limit)
          .toList();
    } else {
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query(
        'plats',
        where: 'nom LIKE ?',
        whereArgs: ['%$query%'],
        limit: limit,
      );


      return result.map((e) => Plat.fromMap(e)).toList();
    }
  }
}
