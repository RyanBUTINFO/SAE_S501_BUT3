import 'package:flutter/material.dart';
import '../repositories/plat_repository.dart';
import '../models/plat.dart';

class SearchPageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> results = [];
  bool isLoading = false;

  Set<String> selectedIngredients = {};
  Set<String> selectedModes = {};
  Set<String> selectedDifficulties = {};
  Set<String> selectedImpacts = {};

  /// Recherche un plat par nom
  Future<void> search(String query) async {
    if (query.isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      results = await _repository.searchPlatsByName(query, limit: 30);
    } catch (e) {
      debugPrint("Erreur recherche plats : $e");
      results = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleFilter(Set<String> filterSet, String value) {
    if (filterSet.contains(value)) {
      filterSet.remove(value);
    } else {
      filterSet.add(value);
    }
    _applyFilters();
  }

  void _applyFilters() {
    List<Plat> filtered = [...results];

    if (selectedIngredients.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.ingredients.any((ing) => selectedIngredients.contains(ing))
      ).toList();
    }

    if (selectedModes.isNotEmpty) {
      filtered = filtered.where((p) =>
        selectedModes.contains(p.modeDeCuisson)
      ).toList();
    }

    if (selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((p) =>
        selectedDifficulties.contains(p.difficulte)
      ).toList();
    }

    if (selectedImpacts.isNotEmpty) {
      filtered = filtered.where((p) =>
        selectedImpacts.contains(p.impactCarbone)
      ).toList();
    }

    // remplace les résultats visibles par les résultats filtrés
    results = filtered;
    notifyListeners();
  }

}
