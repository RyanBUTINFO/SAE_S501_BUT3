// lib/controllers/recommendation_controller.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';

class RecommendationController extends ChangeNotifier {
  final PlatRepository _repo = PlatRepository();

  List<Plat> _recommended = [];
  List<Plat> get recommendedPlats => _recommended;

  bool _loading = false;
  bool get isLoading => _loading;

  DateTime? _lastRefresh;
  static const cacheDuration = Duration(minutes: 10);

  Future<void> loadRecommendedPlats({bool forceRefresh = false}) async {
    if (_loading) return;

    if (!forceRefresh &&
        _recommended.isNotEmpty &&
        _lastRefresh != null &&
        DateTime.now().difference(_lastRefresh!) < cacheDuration) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final allPlats = await _repo.getAllPlats();
      final prefs = await SharedPreferences.getInstance();

      final Set<String> favorites = (prefs.getStringList('favorite_plats') ?? []).toSet();
      final List<String> recent = prefs.getStringList('recently_viewed') ?? [];

      final scored = allPlats.map((plat) {
        double score = 1.0;

        if (plat.id != null && favorites.contains(plat.id.toString())) score += 50;
        if (plat.id != null && recent.contains(plat.id.toString())) score += 15;

        // Boost si végétarien et utilisateur a coché "végétarien"
        if ((plat.type ?? '').toLowerCase().contains('végétarien')) {
          if (prefs.getBool('pref_vegetarian') == true) score += 30;
        }

        // Petit aléatoire pour varier
        score += DateTime.now().millisecond % 20;

        return MapEntry(plat, score);
      }).toList();

      scored.sort((a, b) => b.value.compareTo(a.value));

      _recommended = scored.take(12).map((e) => e.key).toList();

      // Légère variation dans l’ordre après les 3 premiers
      final tail = _recommended.sublist(3);
      tail.shuffle();
      _recommended.replaceRange(3, _recommended.length, tail);

      _lastRefresh = DateTime.now();
    } catch (e) {
      debugPrint("Erreur recommandation: $e");
      // Fallback aléatoire
      final all = await _repo.getAllPlats();
      all.shuffle();
      _recommended = all.take(10).toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadRecommendedPlats(forceRefresh: true);
}