import '../database/database_helper.dart';
import '../models/plat.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math';

class PlatOriginRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Random _random = Random();

  /// 🔹 Retourne 10 plats du pays cible + 10 plats des pays voisins, de manière aléatoire
  Future<Map<String, List<Plat>>> getDiscoveryPlatsGuaranteed(String target) async {
    final db = _dbHelper.sqfliteDb;

    if (!kIsWeb && db == null) return {'target': [], 'neighbors': []};

    // Normalisation du nom
    String keyMap = target.trim();
    if (keyMap.isNotEmpty) keyMap = keyMap[0].toUpperCase() + keyMap.substring(1);
    if (keyMap == "Americain") keyMap = "Américain";

    // 🔹 Plats du pays cible
    List<Plat> targetPlats = [];
    if (!kIsWeb) {
      final resMain = List<Map<String, Object?>>.from(
        await db!.query(
          'plats',
          where: "origine LIKE ? OR cuisine LIKE ?",
          whereArgs: ["%$keyMap%", "%$keyMap%"],
        ),
      );
      // Mélanger et prendre 10
      resMain.shuffle(_random);
      targetPlats = resMain.take(10).map((e) => Plat.fromMap(e)).toList();
    }

    // 🔹 Plats des voisins
    List<String> neighbors = _cuisineTopology[keyMap] ?? [];
    List<Plat> neighborPlats = [];
    if (neighbors.isNotEmpty && !kIsWeb) {
      for (var neighbor in neighbors) {
        final res = List<Map<String, Object?>>.from(
          await db!.query(
            'plats',
            where: "origine LIKE ? OR cuisine LIKE ?",
            whereArgs: ["%$neighbor%", "%$neighbor%"],
          ),
        );
        // Mélange les plats de ce voisin
        res.shuffle(_random);
        // Prends au maximum 2 plats par voisin pour que tous aient une chance
        neighborPlats.addAll(res.take(2).map((e) => Plat.fromMap(e)));
      }
      // Mélange final pour avoir un ordre aléatoire
      neighborPlats.shuffle(_random);
      // Limite à 10 plats
      if (neighborPlats.length > 10) {
        neighborPlats = neighborPlats.take(10).toList();
      }
    }

    return {'target': targetPlats, 'neighbors': neighborPlats};
  }

  static final Map<String, List<String>> _cuisineTopology = {
    'Français': ['Italien', 'Espagnol', 'Belge', 'Suisse', 'Allemand', 'Anglais'],
    'La France': ['Italien', 'Espagnol', 'Belge', 'Suisse', 'Allemand'],
    'Belge': ['Français', 'Hollandais', 'Allemand'],
    'Suisse': ['Français', 'Italien', 'Allemand', 'Autrichien'],
    'Allemand': ['Autrichien', 'Polonais', 'Tchèque', 'Français', 'Belge', 'Hollandais'],
    'Autrichien': ['Allemand', 'Hongrois', 'Tchèque', 'Suisse'],
    'Hollandais': ['Belge', 'Allemand', 'Néerlandais'],
    'Néerlandais': ['Belge', 'Allemand', 'Hollandais'],

    // === 🇬🇧 ÎLES BRITANNIQUES ===
    'Anglais': ['Français', 'Irlandais', 'Écossais', 'Gallois', 'Américain', 'Indien'],
    'Britannique': ['Anglais', 'Irlandais', 'Écossais', 'Gallois'],
    'Irlandais': ['Anglais', 'Britannique', 'Écossais'],
    'Écossais': ['Anglais', 'Britannique', 'Irlandais'],
    'Gallois': ['Anglais', 'Britannique'],

    // === ☀️ EUROPE DU SUD & MÉDITERRANÉE ===
    'Italien': ['Français', 'Grec', 'Espagnol', 'Suisse', 'Autrichien', 'Sicilien'],
    'LItalie': ['Français', 'Grec', 'Espagnol', 'Sicilien'],
    'Sicilien': ['Italien', 'Grec', 'La Méditerranée'],
    'Espagnol': ['Français', 'Portugais', 'Italien', 'Marocain', 'Mexicain', 'Latin'],
    'Portugais': ['Espagnol', 'Brésilien', 'Méditerranéen'],
    'Grec': ['Italien', 'Turc', 'Libanais', 'Moyen-Orient', 'La Méditerranée'],
    'La Grèce': ['Italien', 'Turc', 'Libanais'],
    'La Méditerranée': ['Italien', 'Grec', 'Espagnol', 'Français', 'Libanais'],

    // === ❄️ SCANDINAVIE & EST ===
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

    // === 🇺🇸 AMÉRIQUE DU NORD ===
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

    // === 🌮 MEXIQUE & AMÉRIQUE LATINE ===
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

    // === 🏝️ CARAÏBES ===
    'Caraïbes': ['Jamaïcain', 'Cubain', 'Portoricain', 'Créole'],
    'Caribéen': ['Jamaïcain', 'Cubain', 'Portoricain'],
    'Cubain': ['Espagnol', 'Caribéen', 'Américain'],
    'Jamaïcain': ['Anglais', 'Caribéen', 'Indien'],
    'Portoricain': ['Américain', 'Espagnol', 'Caribéen'],

    // === 🥢 ASIE DE L'EST ===
    'Chinois': ['Japonais', 'Coréen', 'Vietnamien', 'Thaïlandais', 'Sichuan'],
    'La Chine': ['Japonais', 'Coréen', 'Asiatique'],
    'Sichuan': ['Chinois', 'Asiatique'],
    'Japonais': ['Coréen', 'Chinois', 'Hawaïen'],
    'Japon': ['Coréen', 'Chinois'],
    'Coréen': ['Japonais', 'Chinois'],
    'La Corée': ['Japonais', 'Chinois'],
    'Asiatique': ['Chinois', 'Japonais', 'Indien', 'Thaïlandais'],
    'LAsie': ['Chinois', 'Japonais', 'Indien'],

    // === 🍛 ASIE DU SUD & SUD-EST ===
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

    // === 🐪 MOYEN-ORIENT & AFRIQUE DU NORD ===
    'Moyen-Orient': ['Libanais', 'Turc', 'Syrien', 'Égyptien', 'Persan'],
    'Libanais': ['Syrien', 'Turc', 'Grec', 'Israélien', 'Français'],
    'Turc': ['Grec', 'Moyen-Orient', 'Arménien'],
    'Syrien': ['Libanais', 'Turc', 'Moyen-Orient'],
    'Israélien': ['Moyen-Orient', 'Juif', 'Libanais', 'Méditerranéen'],
    'Juif': ['Israélien', 'Europe de lEst', 'Casher', 'Américain'],
    'Casher': ['Juif', 'Israélien'],
    'Arménien': ['Turc', 'Russe', 'Moyen-Orient'],
    'Persan': ['Moyen-Orient', 'Indien', 'Turc'],
    'Afghan': ['Persan', 'Pakistanais', 'Indien'],

    // === 🌍 MAGHREB & AFRIQUE ===
    'Marocain': ['Algérien', 'Tunisien', 'Espagnol', 'Français', 'Couscous'],
    'Algérien': ['Marocain', 'Tunisien', 'Français'],
    'Tunisien': ['Algérien', 'Marocain', 'Italien', 'Français'],
    'Nord-Africain': ['Marocain', 'Algérien', 'Tunisien', 'Égyptien'],
    'Égyptien': ['Moyen-Orient', 'Nord-Africain', 'Grec'],
    'Éthiopien': ['Africain', 'Indien'],
    'Africain': ['Nord-Africain', 'Sud-Africain', 'Caribéen'],
    'Sud-Africain': ['Anglais', 'Hollandais', 'Indien', 'Africain'],

    // === 🐨 OCÉANIE ===
    'Australien': ['Anglais', 'Néo-Zélandais', 'Asiatique'],
    'Néo-Zélandais': ['Australien', 'Anglais'],
    'Hawaïen': ['Américain', 'Japonais', 'Polynésien'],
    // ... le reste
  };
}
