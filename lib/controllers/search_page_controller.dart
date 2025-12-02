import 'package:flutter/material.dart';
import '../repositories/plat_repository.dart';
import '../models/plat.dart';

class SearchPageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> allResults = []; // résultats bruts venant du backend
  List<Plat> results = [];    // résultats filtrés
  bool isLoading = false;

  // 🔥 Filtres actifs
  Set<String> selectedIngredients = {};
  Set<String> selectedDifficulties = {};
  Set<String> selectedImpacts = {};
  Set<String> selectedModes = {};

  /// Recherche par texte (inchangée)
  Future<void> search(String query) async {
    if (query.isEmpty) {
      allResults = [];
      results = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      allResults = await _repository.searchPlatsByName(query, limit: 30);
      _applyFilters();
    } catch (e) {
      debugPrint("Erreur recherche plats : $e");
      allResults = [];
      results = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // 🔥 Active/désactive un filtre
  void toggleFilter(Set<String> filterSet, String value) {
    if (filterSet.contains(value)) {
      filterSet.remove(value);
    } else {
      filterSet.add(value);
    }
    _applyFilters();
  }

  // 🔥 Réinitialiser tous les filtres
  void clearFilters() {
    selectedIngredients.clear();
    selectedDifficulties.clear();
    selectedImpacts.clear();
    _applyFilters();
  }

  // 🔥 Applique les filtres localement sur allResults
  void _applyFilters() {
    List<Plat> filtered = List.from(allResults);

    // Difficulté
    if (selectedDifficulties.isNotEmpty) {
      filtered = filtered.where(
        (p) => selectedDifficulties.contains(p.level ?? "")
      ).toList();
    }

    // Impact écologique
    if (selectedImpacts.isNotEmpty) {
      filtered = filtered.where(
        (p) => selectedImpacts.contains(p.empreinteCarbone ?? "")
      ).toList();
    }

    results = filtered;
    notifyListeners();
  }
}
