import 'package:flutter/material.dart';
import 'dart:math'; // Nécessaire pour min() et max()
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import '../services/recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

    // 2. ⚡ CORRECTION : On RECHARGE les favoris depuis la DB au lieu de les modifier manuellement
    // Cela garantit qu'on a TOUJOURS les vecteurs complets
    _favoritePlats = await _repo.getFavorisWithVectors();
    
    debugPrint(currentlyFavorite 
      ? "❌ Retiré des favoris : ${plat.nom} (Total: ${_favoritePlats.length})"
      : "✅ Ajouté aux favoris : ${plat.nom} (Total: ${_favoritePlats.length})");

    notifyListeners();

    // 3. ⚡ RECHARGEMENT IMMÉDIAT si mode recommandation actif
    if (_isRecommendationMode) {
      debugPrint("🔄 Recalcul des recommandations avec ${_favoritePlats.length} favoris...");
      
      // ON REMET LE LOADING POUR DONNER UN FEEDBACK VISUEL
      _isLoading = true;
      notifyListeners();
      
      await _loadVectorRecommendations();
      
      _isLoading = false;
      notifyListeners();
      
      debugPrint("✅ Recommandations mises à jour !");
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
    // 1. Charger les préférences (Ingrédients interdits & Objectifs)
    final prefs = await SharedPreferences.getInstance();
    
    List<String> avoidedIngredients = [];
    if (prefs.getString('avoided_ingredients') != null) {
      avoidedIngredients = List<String>.from(jsonDecode(prefs.getString('avoided_ingredients')!));
    }
    
    List<String> objectifs = [];
    if (prefs.getString('objectifs') != null) {
      objectifs = List<String>.from(jsonDecode(prefs.getString('objectifs')!));
    }

    // 2. Récupérer TOUS les plats
    List<Plat> allPlats = await _repo.getAllPlatsWithVectors();

    // 3. Appliquer l'exclusion (Si l'utilisateur a des allergies)
    if (avoidedIngredients.isNotEmpty) {
      Set<int> forbiddenIds = await _repo.getPlatIdsWithIngredients(avoidedIngredients);
      // On retire les plats interdits de la liste
      allPlats.removeWhere((p) => forbiddenIds.contains(p.id));
    }

    // Gestion du démarrage à froid (Cold Start)
    if (_favoritePlats.isEmpty) {
      debugPrint("⚠️ Aucun favori → Mode découverte");
      allPlats.shuffle();
      _currentPlats = allPlats.take(15).toList();
      return;
    }

    // 4. 🎯 DEBUG : Afficher les favoris pris en compte
    debugPrint("📊 Calcul avec ${_favoritePlats.length} favoris :");
    for (var fav in _favoritePlats) {
      String vectorPreview = fav.vector.length >= 3 
          ? fav.vector.take(3).toList().toString()
          : "[]";
      debugPrint("   - ${fav.nom} (vecteur: $vectorPreview...)");
    }

    // 5. Calcul du vecteur & Matching
    List<double> userProfileVector = _recommendationService.computeUserProfileVector(_favoritePlats);
    
    // 🎯 DEBUG : Afficher le profil généré
    debugPrint("🧬 Profil utilisateur généré : ${userProfileVector.take(5).toList()}...");
    
    _currentPlats = _recommendationService.getBestMatches(allPlats, userProfileVector, objectifs);

    // 6. 🎯 DEBUG : Afficher les top recommandations
    debugPrint("🏆 Top 5 recommandations :");
    for (var i = 0; i < 5 && i < _currentPlats.length; i++) {
      debugPrint("   ${i+1}. ${_currentPlats[i].nom}");
    }

    // 7. Monitoring
    lastExecutionTime = _recommendationService.lastExecutionTimeMs;
    _executionHistory.add(lastExecutionTime);
    if (_executionHistory.length > 50) _executionHistory.removeAt(0);
  }
}
