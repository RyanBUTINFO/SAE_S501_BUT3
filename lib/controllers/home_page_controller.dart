import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import '../repositories/plat_origin_repository.dart';
import '../Views/infos_plat.dart'; // <<< Import de la page de destination

class HomePageController extends ChangeNotifier {
  final PlatRepository _repo = PlatRepository();
  final PlatOriginRepository _originRepo = PlatOriginRepository();

  // --- STATE ---
  List<Plat> _currentPlats = []; 
  List<Plat> get currentPlats => _currentPlats;

  // Pour compatibilité
  List<Plat> get randomPlats => _currentPlats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecommendationMode = false; // false = Découverte, true = Recommandation
  bool get isRecommendationMode => _isRecommendationMode;

  // --- SWITCH MODE ---
  void setMode(bool recommendationMode) {
    _isRecommendationMode = recommendationMode;
    loadData(); 
  }

  // --- LOAD DATA (Routeur principal) ---
  Future<void> loadData() async {
    if (_isLoading) return;

    if (_isRecommendationMode) {
      await _loadRecommendationMode();
    } else {
      await _loadDiscoveryMode();
    }
  }

  // --- MODE 1 : DÉCOUVERTE (Random) ---
  Future<void> _loadDiscoveryMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentPlats = await _repo.getRandomPlats(limit: 15);
      
      // ignore: unnecessary_null_comparison
      if (_currentPlats == null) _currentPlats = [];

    } catch (e) {
      debugPrint("Erreur Mode Découverte: $e");
      _currentPlats = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- MODE 2 : RECOMMANDATION (Preferences) ---
  Future<void> _loadRecommendationMode() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final cuisinesJson = prefs.getString('cuisines');
      
      String target = "Italien"; // Valeur par défaut

      if (cuisinesJson != null) {
        List<String> favCuisines = List<String>.from(jsonDecode(cuisinesJson));
        if (favCuisines.isNotEmpty) {
          target = favCuisines[Random().nextInt(favCuisines.length)];
        }
      }

      _currentPlats = await _originRepo.getDiscoveryPlatsGuaranteed(target);
      
      if (_currentPlats.isEmpty) {
        _currentPlats = await _repo.getRandomPlats(limit: 15);
      }

    } catch (e) {
      debugPrint("Erreur Mode Recommandation: $e");
      _currentPlats = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // --- MÉTHODE CRUCIALE : GESTION DU CLIC ET ENRICHISSEMENT ---
  // ----------------------------------------------------------------------

  /// Gère le clic sur un plat : enrichit l'objet Plat et navigue vers la page de détails.
  Future<void> onPlatTapped(BuildContext context, Plat plat) async {
    
    // 1. Déclenche l'enrichissement des données complexes (ingrédients, JSON)
    // C'est ICI que le contrôleur reçoit le Plat enrichi du repository.
    Plat platEnrichi = await _repo.enrichirPlatPourDetails(plat); // <<< L'objet enrichi est reçu ici !

    // 2. Navigation vers la page de détails, en passant l'objet enrichi
    Navigator.push(
      context,
      MaterialPageRoute(
        // CORRECTION: Utilisation de InfosPlat, conformément à l'import '../views/infos_plat.dart'
        builder: (context) => RecipePage(plat: platEnrichi), 
      ),
    );
  }
}