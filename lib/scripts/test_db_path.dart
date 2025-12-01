import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Récupère le chemin des bases de données sur l'appareil
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, 'base_miaam.db');

    print('Chemin complet de la DB : $path');

    // Ouvre la base de données
    final db = await sqflite.openDatabase(path);

    try {
      // Récupère 5 plats pour tester
      final result = await db.query('plats', limit: 5);
      for (var row in result) {
        print(row);
      }
    } finally {
      // Ferme la base de données même si une erreur survient
      await db.close();
    }
  } catch (e) {
    print('Erreur lors de l\'ouverture ou de la lecture de la base : $e');
  }
}
