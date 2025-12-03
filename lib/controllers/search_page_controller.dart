import 'package:flutter/material.dart';
import '../repositories/plat_repository.dart';
import '../models/plat.dart';

class SearchPageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> results = [];
  bool isLoading = false;

  // --- ÉTATS DES FILTRES (Listes complètes) ---
  List<String> selectedDifficulties = [];
  List<String> selectedIngredients = [];
  List<String> selectedCookingModes = [];
  List<String> selectedEcoImpacts = []; // Présent pour l'UI, même si non filtré en SQL pour l'instant

  String currentQuery = "";

  /// Met à jour la recherche texte
  void setQuery(String query) {
    currentQuery = query;
    search();
  }

  /// Fonction générique pour cocher/décocher un filtre
  void toggleFilter(List<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
    notifyListeners(); // Met à jour l'affichage (couleur verte)
    search();          // Lance la recherche immédiatement
  }

  /// Lance la recherche globale
  Future<void> search() async {
    // Si tout est vide, on vide la liste
    if (currentQuery.isEmpty &&
        selectedDifficulties.isEmpty &&
        selectedIngredients.isEmpty &&
        selectedCookingModes.isEmpty &&
        selectedEcoImpacts.isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      results = await _repository.searchPlatsByCriteria(
        query: currentQuery,
        difficulties: selectedDifficulties,
        ingredients: selectedIngredients,
        cookingModes: selectedCookingModes,
        // ecoImpacts: selectedEcoImpacts, // On ne l'envoie pas au repo pour l'instant pour éviter les erreurs
      );
    } catch (e) {
      debugPrint("Erreur recherche : $e");
      results = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    selectedDifficulties.clear();
    selectedIngredients.clear();
    selectedCookingModes.clear();
    selectedEcoImpacts.clear();
    
    // On garde la recherche textuelle si l'utilisateur a tapé quelque chose
    search();
  }
}