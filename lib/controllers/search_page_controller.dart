import 'package:flutter/material.dart';
import '../repositories/plat_repository.dart';
import '../models/plat.dart';

class SearchPageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> results = [];
  bool isLoading = false;

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
}
