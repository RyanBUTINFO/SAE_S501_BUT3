import 'dart:math';
import '../models/plat.dart';

class RecommendationService {
  
  /// Test 1 : Calcul de la similarité cosinus (Inchangé)
  double calculateCosineSimilarity(List<double> v1, List<double> v2) {
    if (v1.isEmpty || v2.isEmpty) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normA += pow(v1[i], 2);
      normB += pow(v2[i], 2);
    }

    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// NOUVELLE MÉTHODE : Création du profil utilisateur (L'Évolution)
  /// Elle prend les favoris récupérés par le Repo et en fait une moyenne.
  List<double> computeUserProfileVector(List<Plat> favoris) {
    if (favoris.isEmpty) return [];

    // On initialise un vecteur de 27 zéros
    List<double> profileVector = List.filled(27, 0.0);

    // Somme des vecteurs de tous les favoris
    for (var plat in favoris) {
      if (plat.vector.length == 27) {
        for (int i = 0; i < 27; i++) {
          profileVector[i] += plat.vector[i];
        }
      }
    }

    // Calcul de la moyenne pour chaque dimension
    return profileVector.map((val) => val / favoris.length).toList();
  }

  /// Algorithme Top-K (Inchangé)
  List<Plat> getBestMatches(List<Plat> allPlats, List<double> targetVector) {
    if (targetVector.isEmpty) return [];

    // 1. Calcul des scores
    List<Map<String, dynamic>> scoredList = allPlats.map((plat) {
      double score = calculateCosineSimilarity(targetVector, plat.vector);
      return {'plat': plat, 'score': score};
    }).toList();

    // 2. Tri par score décroissant
    scoredList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // --- TEST 1 : AFFICHAGE DANS LE TERMINAL ---
    print("\n --- RÉSULTATS DE L'ALGO VECTORIEL ---");
    for (int i = 0; i < 10; i++) {
      if (i < scoredList.length) {
        final name = scoredList[i]['plat'].nom;
        final score = scoredList[i]['score'].toStringAsFixed(4);
        print("Rang ${i + 1} : $name | Score: $score");
      }
    }
    print("------------------------------------------\n");

    // 3. Retourne le Top 20
    return scoredList.take(20).map((e) => e['plat'] as Plat).toList();
  }
}