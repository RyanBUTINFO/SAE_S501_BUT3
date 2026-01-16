import 'package:flutter/material.dart';
import 'dart:math'; // Nécessaire pour min() et max()
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import '../services/recommendation_service.dart';

class HomePageController extends ChangeNotifier {
  final PlatRepository _repo = PlatRepository();
  final RecommendationService _recommendationService = RecommendationService();

  // --- ÉTATS ---
  List<Plat> _currentPlats = [];
  List<Plat> get currentPlats => _currentPlats;

  List<Plat> _favoritePlats = []; 
  List<Plat> get favoritePlats => _favoritePlats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecommendationMode = false;
  bool get isRecommendationMode => _isRecommendationMode;

  // --- MONITORING & PERFORMANCES (NOUVEAU) ---
  int lastExecutionTime = 0;
  final List<int> _executionHistory = []; // Historique pour les stats

  // Getters pour l'interface (Calculs dynamiques)
  int get minTime => _executionHistory.isEmpty ? 0 : _executionHistory.reduce(min);
  int get maxTime => _executionHistory.isEmpty ? 0 : _executionHistory.reduce(max);
  double get avgTime => _executionHistory.isEmpty 
      ? 0.0 
      : _executionHistory.reduce((a, b) => a + b) / _executionHistory.length;

  // --- INITIALISATION ---
  HomePageController() {
    _initFavorites(); 
  }

  // --- GESTION DES FAVORIS ---
  Future<void> _initFavorites() async {
    _isLoading = true;
    notifyListeners();

    _favoritePlats = await _repo.getFavorisWithVectors();
    
    await loadData(); 
  }

  bool isFavorite(int? id) => _favoritePlats.any((p) => p.id == id);

  void toggleFavorite(Plat plat) async {
    if (plat.id == null) return;

    bool currentlyFavorite = isFavorite(plat.id);

    // 1. Mise à jour DB
    await _repo.toggleFavori(plat.id!, !currentlyFavorite);

    // 2. Mise à jour État Local
    if (currentlyFavorite) {
      _favoritePlats.removeWhere((p) => p.id == plat.id);
    } else {
      _favoritePlats.add(plat);
    }

    notifyListeners();

    // 3. Si mode recommandation actif, on relance le calcul pour voir l'impact temps réel
    if (_isRecommendationMode) {
      await _loadVectorRecommendations();
      notifyListeners();
    }
  }

  // --- LOGIQUE DE NAVIGATION ---
  void setMode(bool recommendationMode) {
    _isRecommendationMode = recommendationMode;
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isRecommendationMode) {
        await _loadVectorRecommendations();
      } else {
        await _loadDiscoveryMode();
      }
    } catch (e) {
      debugPrint("❌ Erreur dans loadData : $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mode Aléatoire (Pas de monitoring ici car pas d'algo lourd)
  Future<void> _loadDiscoveryMode() async {
    List<Plat> all = await _repo.getAllPlatsWithVectors();
    all.shuffle();
    _currentPlats = all.take(15).toList();
  }

  // Mode Recommandation (C'est ici qu'on mesure)
  Future<void> _loadVectorRecommendations() async {
    List<Plat> allPlats = await _repo.getAllPlatsWithVectors();

    if (_favoritePlats.isEmpty) {
      // Cold Start
      allPlats.shuffle();
      _currentPlats = allPlats.take(15).toList();
      return;
    }

    // 1. Profil Utilisateur
    List<double> userProfileVector = _recommendationService.computeUserProfileVector(_favoritePlats);

    // 2. Matching (L'algo tourne ici)
    _currentPlats = _recommendationService.getBestMatches(allPlats, userProfileVector);

    // --- 3. RÉCUPÉRATION DES MÉTRIQUES (Mise à jour) ---
    lastExecutionTime = _recommendationService.lastExecutionTimeMs;
    
    // On ajoute à l'historique pour les stats
    _executionHistory.add(lastExecutionTime);
    
    // On garde un historique raisonnable (ex: 50 dernières mesures)
    if (_executionHistory.length > 50) _executionHistory.removeAt(0);
  }
}