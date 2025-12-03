import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatOriginRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 Returns a merged LIST (10 targets + 10 neighbors)
  Future<List<Plat>> getDiscoveryPlatsGuaranteed(String target) async {
    final db = _dbHelper.sqfliteDb;
    
    // Safety check: if DB is not open (on mobile), return empty
    if (!kIsWeb && db == null) return [];

    // 1️⃣ Normalization
    String keyMap = target.trim();
    if (keyMap.isNotEmpty) {
      keyMap = keyMap[0].toUpperCase() + keyMap.substring(1);
    }
    // Specific fix for "Americain" -> "Américain" to match the map keys
    if (keyMap == "Americain") keyMap = "Américain";

    // 2️⃣ Targets
    List<Plat> mainList = [];
    if (!kIsWeb) {
      final resMain = await db!.query(
        'plats',
        where: "cuisine LIKE ?",
        whereArgs: ["%$keyMap%"],
        orderBy: 'RANDOM()',
        limit: 10,
      );
      mainList = resMain.map((e) => Plat.fromMap(e)).toList();
    }

    // 3️⃣ Neighbors
    List<String> neighbors = [];
    if (_cuisineTopology.containsKey(keyMap)) {
      neighbors = _cuisineTopology[keyMap]!;
    }

    List<Plat> neighborList = [];
    if (neighbors.isNotEmpty && !kIsWeb) {
      List<String> whereClauses = [];
      List<String> args = [];
      for (var n in neighbors) {
        whereClauses.add("cuisine LIKE ?");
        args.add("%$n%");
      }
      
      if (whereClauses.isNotEmpty) {
        final resNeighbors = await db!.query(
          'plats',
          where: whereClauses.join(" OR "),
          whereArgs: args,
          orderBy: 'RANDOM()',
          limit: 10,
        );
        neighborList = resNeighbors.map((e) => Plat.fromMap(e)).toList();
      }
    }

    // 4️⃣ Merge and return a LIST
    final all = [...mainList, ...neighborList];
    final uniqueIds = <int>{};
    return all.where((p) => p.id != null && uniqueIds.add(p.id!)).toList();
  }

  // ==================== TOPOLOGY MAP ====================
  static final Map<String, List<String>> _cuisineTopology = {
    'Français': ['Italien', 'Espagnol', 'Belge', 'Suisse', 'Allemand', 'Anglais'],
    'La France': ['Italien', 'Espagnol', 'Belge', 'Suisse', 'Allemand'],
    'Belge': ['Français', 'Hollandais', 'Allemand'],
    'Suisse': ['Français', 'Italien', 'Allemand', 'Autrichien'],
    'Allemand': ['Autrichien', 'Polonais', 'Tchèque', 'Français', 'Belge', 'Hollandais'],
    'Autrichien': ['Allemand', 'Hongrois', 'Tchèque', 'Suisse'],
    'Hollandais': ['Belge', 'Allemand', 'Néerlandais'],
    'Néerlandais': ['Belge', 'Allemand', 'Hollandais'],
    'Anglais': ['Français', 'Irlandais', 'Écossais', 'Gallois', 'Américain', 'Indien'],
    'Britannique': ['Anglais', 'Irlandais', 'Écossais', 'Gallois'],
    'Irlandais': ['Anglais', 'Britannique', 'Écossais'],
    'Écossais': ['Anglais', 'Britannique', 'Irlandais'],
    'Gallois': ['Anglais', 'Britannique'],
    'Italien': ['Français', 'Grec', 'Espagnol', 'Suisse', 'Autrichien', 'Sicilien'],
    'LItalie': ['Français', 'Grec', 'Espagnol', 'Sicilien'],
    'Sicilien': ['Italien', 'Grec', 'La Méditerranée'],
    'Espagnol': ['Français', 'Portugais', 'Italien', 'Marocain', 'Mexicain', 'Latin'],
    'Portugais': ['Espagnol', 'Brésilien', 'Méditerranéen'],
    'Grec': ['Italien', 'Turc', 'Libanais', 'Moyen-Orient', 'La Méditerranée'],
    'La Grèce': ['Italien', 'Turc', 'Libanais'],
    'La Méditerranée': ['Italien', 'Grec', 'Espagnol', 'Français', 'Libanais'],
    'Scandinave': ['Suédois', 'Norvégien', 'Danois', 'Finlandais', 'Allemand'],
    'Suédois': ['Norvégien', 'Danois', 'Finlandais'],
    'Norvégien': ['Suédois', 'Danois'],
    'Danois': ['Suédois', 'Norvégien', 'Allemand'],
    'Finlandais': ['Suédois', 'Russe', 'Scandinave'],
    'Russe': ['Ukrainien', 'Polonais', 'Finlandais', 'Europe de lEst'],
    'Polonais': ['Allemand', 'Tchèque', 'Russe', 'Ukrainien'],
    'Tchèque': ['Allemand', 'Autrichien', 'Polonais', 'Hongrois'],
    'Hongrois': ['Autrichien', 'Tchèque', 'Europe de lEst'],
    'Ukrainien': ['Russe', 'Polonais', 'Europe de lEst'],
    'Europe de lEst': ['Russe', 'Polonais', 'Hongrois', 'Tchèque'],
    'Américain': ['Canadien', 'Mexicain', 'Anglais', 'Cajun', 'Créole', 'Du sud'],
    'États-Unis': ['Américain', 'Canadien', 'Mexicain'],
    'Canadien': ['Américain', 'Français', 'Canadien français'],
    'Canadien français': ['Canadien', 'Français'],
    'Cajun': ['Américain', 'Créole', 'Français', 'Du sud'],
    'Créole': ['Cajun', 'Caribéen', 'Américain'],
    'Du sud': ['Américain', 'Cajun', 'Tex-Mex'],
    'Nouvelle-Angleterre': ['Américain', 'Canadien', 'Anglais'],
    'Sud-Ouest': ['Américain', 'Mexicain', 'Tex-Mex'],
    'Amérindien': ['Américain', 'Mexicain'],
    'Amish': ['Allemand', 'Américain'],
    'Mexicain': ['Américain', 'Tex-Mex', 'Espagnol', 'Argentin', 'Colombien'],
    'Mexique': ['Américain', 'Tex-Mex', 'Espagnol'],
    'Tex-Mex': ['Mexicain', 'Américain', 'Du sud'],
    'Latino': ['Mexicain', 'Caribéen', 'Sud-Américain', 'Espagnol'],
    'Amérique latine': ['Mexicain', 'Argentin', 'Brésilien', 'Colombien'],
    'Argentin': ['Espagnol', 'Italien', 'Chilien', 'Brésilien', 'Sud-Américain'],
    'Brésilien': ['Portugais', 'Argentin', 'Sud-Américain'],
    'Chilien': ['Argentin', 'Péruvien', 'Sud-Américain'],
    'Colombien': ['Vénézuélien', 'Péruvien', 'Mexicain'],
    'Vénézuélien': ['Colombien', 'Caribéen', 'Sud-Américain'],
    'Péruvien': ['Chilien', 'Colombien', 'Japonais'],
    'Salvadorien': ['Mexicain', 'Latino'],
    'Sud-Américain': ['Argentin', 'Brésilien', 'Chilien', 'Péruvien'],
    'Caraïbes': ['Jamaïcain', 'Cubain', 'Portoricain', 'Créole'],
    'Caribéen': ['Jamaïcain', 'Cubain', 'Portoricain'],
    'Cubain': ['Espagnol', 'Caribéen', 'Américain'],
    'Jamaïcain': ['Anglais', 'Caribéen', 'Indien'],
    'Portoricain': ['Américain', 'Espagnol', 'Caribéen'],
    'Chinois': ['Japonais', 'Coréen', 'Vietnamien', 'Thaïlandais', 'Sichuan'],
    'La Chine': ['Japonais', 'Coréen', 'Asiatique'],
    'Sichuan': ['Chinois', 'Asiatique'],
    'Japonais': ['Coréen', 'Chinois', 'Hawaïen'],
    'Japon': ['Coréen', 'Chinois'],
    'Coréen': ['Japonais', 'Chinois'],
    'La Corée': ['Japonais', 'Chinois'],
    'Asiatique': ['Chinois', 'Japonais', 'Indien', 'Thaïlandais'],
    'LAsie': ['Chinois', 'Japonais', 'Indien'],
    'Indien': ['Pakistanais', 'Sri Lankais', 'Anglais', 'Asiatique'],
    'LInde': ['Pakistanais', 'Sri Lankais'],
    'Pakistanais': ['Indien', 'Moyen-Orient', 'Afghan'],
    'Sri Lankais': ['Indien', 'Asiatique'],
    'Bangladais': ['Indien', 'Asiatique'],
    'Thaïlandais': ['Vietnamien', 'Chinois', 'Malaisien', 'Indonésien'],
    'La Thaïlande': ['Vietnamien', 'Chinois'],
    'Vietnamien': ['Thaïlandais', 'Chinois', 'Français'],
    'Indonésien': ['Malaisien', 'Thaïlandais', 'Hollandais'],
    'Malaisien': ['Indonésien', 'Thaïlandais', 'Indien', 'Chinois'],
    'Philippin': ['Espagnol', 'Américain', 'Asiatique', 'Malaisien'],
    'Moyen-Orient': ['Libanais', 'Turc', 'Syrien', 'Égyptien', 'Perse'],
    'Libanais': ['Syrien', 'Turc', 'Grec', 'Israélien', 'Français'],
    'Turc': ['Grec', 'Moyen-Orient', 'Arménien'],
    'Syrien': ['Libanais', 'Turc', 'Moyen-Orient'],
    'Israélien': ['Moyen-Orient', 'Juif', 'Libanais', 'Méditerranéen'],
    'Juif': ['Israélien', 'Europe de lEst', 'Casher', 'Américain'],
    'Casher': ['Juif', 'Israélien'],
    'Arménien': ['Turc', 'Russe', 'Moyen-Orient'],
    'Persan': ['Moyen-Orient', 'Indien', 'Turc'],
    'Afghan': ['Persan', 'Pakistanais', 'Indien'],
    'Marocain': ['Algérien', 'Tunisien', 'Espagnol', 'Français', 'Couscous'],
    'Algérien': ['Marocain', 'Tunisien', 'Français'],
    'Tunisien': ['Algérien', 'Marocain', 'Italien', 'Français'],
    'Nord-Africain': ['Marocain', 'Algérien', 'Tunisien', 'Égyptien'],
    'Égyptien': ['Moyen-Orient', 'Nord-Africain', 'Grec'],
    'Éthiopien': ['Africain', 'Indien'],
    'Africain': ['Nord-Africain', 'Sud-Africain', 'Caribéen'],
    'Sud-Africain': ['Anglais', 'Hollandais', 'Indien', 'Africain'],
    'Australien': ['Anglais', 'Néo-Zélandais', 'Asiatique'],
    'Néo-Zélandais': ['Australien', 'Anglais'],
    'Hawaïen': ['Américain', 'Japonais', 'Polynésien'],
  };
}