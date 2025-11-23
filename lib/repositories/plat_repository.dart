import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';

class PlatRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Plat>> getTopPlatsByOrigine(String origine, {int limit = 10}) async {
  if (kIsWeb) {
    final store = intMapStoreFactory.store('plats');
    final snapshot = await store.find(_dbHelper.sembastDb!);

    return snapshot.map((record) {
      final plat = Plat.fromMap(record.value);
      if (plat.origine != null && plat.origine!.toLowerCase().contains(origine.toLowerCase())) {
        return plat;
      }
      return null;
    }).whereType<Plat>().take(limit).toList();
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

}
