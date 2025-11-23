import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbPath = await sqflite.getDatabasesPath();
  final path = join(dbPath, 'base_miaam.db');

  print('Chemin complet de la DB : $path');

  // Optionnel : ouvrir et lire quelques lignes
  final db = await sqflite.openDatabase(path);
  final result = await db.query('plats', limit: 5); // récupère 5 plats pour test
  for (var row in result) {
    print(row);
  }

  await db.close();
}
