

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
      // Utilisation de votre getter sqfliteDb!
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
      // Utilisation de votre getter sqfliteDb!
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query('plats');
      final random = Random();
      final shuffled = List.of(result)..shuffle(random);

      return shuffled.take(limit).map((e) {
        final plat = Plat.fromMap(e);

        // La logique redondante d'affectation des alias a été supprimée
        // pour résoudre le problème de compilation.
        return plat;
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
      // Utilisation de votre getter sqfliteDb!
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

  // ==================== AJOUTÉES ====================

  /// Récupère TOUS les plats (nécessaire pour les recommandations)
  Future<List<Plat>> getAllPlats() async {
    if (kIsWeb) {
      final store = intMapStoreFactory.store('plats');
      final snapshot = await store.find(_dbHelper.sembastDb!);
      return snapshot.map((record) => Plat.fromMap(record.value)).toList();
    } else {
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query('plats');
      return result.map((e) => Plat.fromMap(e)).toList();
    }
  }

  /// Récupère un plat par son ID (nécessaire pour la page détail)
  Future<Plat?> getPlatById(String id) async {
    if (kIsWeb) {
      final store = intMapStoreFactory.store('plats');
      final record = await store.record(int.tryParse(id) ?? -1).get(_dbHelper.sembastDb!);
      if (record == null) return null;
      return Plat.fromMap(record as Map<String, dynamic>);
    } else {
      final db = _dbHelper.sqfliteDb!;
      final result = await db.query(
        'plats',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return Plat.fromMap(result.first);
    }
  }
}