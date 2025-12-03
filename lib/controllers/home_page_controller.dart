import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import '../repositories/plat_origin_repository.dart';

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
  // Modifié pour actualiser même si on clique sur le même mode
  void setMode(bool recommendationMode) {
    // On met à jour la variable (même si c'est la même valeur, ce n'est pas grave)
    _isRecommendationMode = recommendationMode;
    
    // On force le rechargement des données à chaque clic
    loadData(); 
  }

  // --- LOAD DATA (Routeur principal) ---
  Future<void> loadData() async {
    // Si une requête est déjà en cours, on ne fait rien pour éviter les bugs visuels
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
    notifyListeners(); // Affiche le rond de chargement

    try {
      // Récupère 15 nouvelles recettes aléatoires
      _currentPlats = await _repo.getRandomPlats(limit: 15);
      
      // Sécurité anti-crash
      // ignore: unnecessary_null_comparison
      if (_currentPlats == null) _currentPlats = [];

    } catch (e) {
      debugPrint("Erreur Mode Découverte: $e");
      _currentPlats = [];
    }

    _isLoading = false;
    notifyListeners(); // Affiche les résultats
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
          // Prend une cuisine aléatoire parmi les favorites pour changer à chaque clic
          target = favCuisines[Random().nextInt(favCuisines.length)];
        }
      }

      // Récupération des plats recommandés
      _currentPlats = await _originRepo.getDiscoveryPlatsGuaranteed(target);
      
      // Fallback si vide
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
}