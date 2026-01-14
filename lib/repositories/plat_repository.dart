import 'package:flutter/material.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import '../services/recommendation_service.dart';

class HomePageController extends ChangeNotifier {
  final PlatRepository _repo = PlatRepository();
  final RecommendationService _recommendationService = RecommendationService();

  // --- ÉTATS ---
  List<Plat> _currentPlats = [];
  List<Plat> get currentPlats => _currentPlats;

  List<Plat> _favoritePlats = []; // Contient maintenant les plats AVEC leurs vecteurs
  List<Plat> get favoritePlats => _favoritePlats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecommendationMode = false;
  bool get isRecommendationMode => _isRecommendationMode;

  // --- INITIALISATION ---
  HomePageController() {
    _initFavorites(); 
  }

  // --- GESTION DES FAVORIS (VERSION SQLITE ÉVOLUTIVE) ---
  
  Future<void> _initFavorites() async {
    _isLoading = true;
    notifyListeners();

    // On récupère les favoris avec leurs vecteurs SVD directement depuis SQLite
    _favoritePlats = await _repo.getFavorisWithVectors();
    
    await loadData(); // Charge les plats de l'accueil
  }

  bool isFavorite(int? id) => _favoritePlats.any((p) => p.id == id);

  void toggleFavorite(Plat plat) async {
    if (plat.id == null) return;

    bool currentlyFavorite = isFavorite(plat.id);

    // 1. Mise à jour dans la base de données (Table 'favoris')
    await _repo.toggleFavori(plat.id!, !currentlyFavorite);

    // 2. Mise à jour de l'état local pour l'UI
    if (currentlyFavorite) {
      _favoritePlats.removeWhere((p) => p.id == plat.id);
    } else {
      // On s'assure d'ajouter le plat avec son vecteur pour l'algo
      _favoritePlats.add(plat);
    }

    notifyListeners();

    // 3. Si on est en mode recommandation, on recalcule le profil immédiatement
    if (_isRecommendationMode) {
      await _loadVectorRecommendations();
      notifyListeners();
    }
  }

  // --- LOGIQUE DE NAVIGATION / MODES ---

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

  // Mode Aléatoire / Découverte
  Future<void> _loadDiscoveryMode() async {
    List<Plat> all = await _repo.getAllPlatsWithVectors();
    all.shuffle();
    _currentPlats = all.take(15).toList();
  }

  // Mode Recommandation Personnalisée (Évolutif)
  Future<void> _loadVectorRecommendations() async {
    List<Plat> allPlats = await _repo.getAllPlatsWithVectors();

    if (_favoritePlats.isEmpty) {
      // Cold Start : Si aucun favori, on propose du contenu varié
      allPlats.shuffle();
      _currentPlats = allPlats.take(15).toList();
      return;
    }

    // 1. GÉNÉRATION DU PROFIL : L'algorithme calcule la moyenne des vecteurs des favoris
    // Cette "cible" évolue à chaque nouveau favori ajouté.
    List<double> userProfileVector = _recommendationService.computeUserProfileVector(_favoritePlats);

    // 2. MATCHING : On compare ce profil moyen à toute la base de données
    _currentPlats = _recommendationService.getBestMatches(allPlats, userProfileVector);
  }
}