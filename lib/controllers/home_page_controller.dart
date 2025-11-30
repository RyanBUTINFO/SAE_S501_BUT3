import 'package:flutter/material.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';

class HomePageController extends ChangeNotifier {
  final PlatRepository _repository = PlatRepository();

  List<Plat> randomPlats = [];
  bool isLoading = false;

  Future<void> loadRandomPlats() async {
    isLoading = true;
    notifyListeners();

    try {
      randomPlats = await _repository.getRandomPlats(limit: 13);
    } catch (e) {
      debugPrint("Erreur lors du chargement des plats : $e");
      randomPlats = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
