import 'package:flutter/material.dart';
import '../repositories/plat_repository.dart';
import '../models/plat.dart';

class SearchPageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> results = [];
  bool isLoading = false;
  
  // État du Frigo
  List<Map<String, dynamic>> fridgeIngredients = [];
  List<Map<String, dynamic>> ingredientSuggestions = [];

  List<String> selectedDifficulties = [];
  String currentQuery = "";

  // Chercher des ingrédients pour les ajouter au frigo
  Future<void> updateIngredientSuggestions(String query) async {
    ingredientSuggestions = await _repository.searchIngredients(query);
    notifyListeners();
  }

  void addToFridge(Map<String, dynamic> ingredient) {
    if (!fridgeIngredients.any((e) => e['id'] == ingredient['id'])) {
      fridgeIngredients.add(ingredient);
      search();
    }
  }

  void removeFromFridge(int id) {
    fridgeIngredients.removeWhere((e) => e['id'] == id);
    search();
  }

  void setQuery(String query) {
    currentQuery = query;
    search();
  }

  void toggleFilter(List<String> list, String value) {
    list.contains(value) ? list.remove(value) : list.add(value);
    notifyListeners();
    search();
  }

  Future<void> search() async {
    isLoading = true;
    notifyListeners();

    if (fridgeIngredients.isNotEmpty) {
      // MODE FRIGO : afficher les plats contenant au moins certains ingrédients
      List<int> ids = fridgeIngredients.map((e) => e['id'] as int).toList();
      results = await _repository.getPlatsByIngredients(ids);
    } else if (currentQuery.isNotEmpty || selectedDifficulties.isNotEmpty) {
      // MODE TEXTE CLASSIQUE
      results = await _repository.search(currentQuery, selectedDifficulties);
    } else {
      results = [];
    }

    isLoading = false;
    notifyListeners();
  }
}