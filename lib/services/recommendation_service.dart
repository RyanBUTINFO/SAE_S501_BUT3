import 'dart:math';
import '../models/plat.dart';

class RecommendationService {
  
  // Variable pour le rapport de performance (SAÉ)
  int lastExecutionTimeMs = 0;

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

  List<double> computeUserProfileVector(List<Plat> favoris) {
    if (favoris.isEmpty) return [];
    List<double> profileVector = List.filled(27, 0.0);
    for (var plat in favoris) {
      if (plat.vector.length == 27) {
        for (int i = 0; i < 27; i++) {
          profileVector[i] += plat.vector[i];
        }
      }
    }
    return profileVector.map((val) => val / favoris.length).toList();
  }

  // Modifie la signature pour accepter 'userGoals'
  List<Plat> getBestMatches(List<Plat> allPlats, List<double> targetVector, List<String> userGoals) {
    if (targetVector.isEmpty) return [];

    final stopwatch = Stopwatch()..start();

    List<Map<String, dynamic>> scoredList = allPlats.map((plat) {
      // 1. Score de base (Similitude Cosinus)
      // Cela mesure à quel point le plat ressemble aux favoris (ingrédients, style...)
      double score = calculateCosineSimilarity(targetVector, plat.vector);

      // 2. --- AJUSTEMENT SELON LES OBJECTIFS (BONUS) ---
      
      // Bonus : Rapide (< 30 min)
      if (userGoals.contains('Rapide (<30min)')) {
        double tempsTotal = (plat.tempsPreparation ?? 0) + (plat.tempsCuisson ?? 0);
        if (tempsTotal > 0 && tempsTotal <= 30) {
          score += 0.15; // Bonus de 15%
        }
      }

      // Bonus : Faible en calories (< 500 kcal)
      // Note : On met 9999 si null pour ne pas favoriser par erreur les plats sans info
      if (userGoals.contains('Faible en calories')) {
        if ((plat.calories ?? 9999) < 500) {
          score += 0.10; // Bonus de 10%
        }
      }

      // Bonus : Végétarien
      // On regarde si le type ou le nom contient "Végé"
      if (userGoals.contains('Végétarien')) {
         if ((plat.type?.contains("Végé") ?? false) || (plat.nom.contains("Végé"))) {
           score += 0.20; // Gros bonus de 20%
         }
      }

      return {'plat': plat, 'score': score};
    }).toList();

    // Tri du plus grand score au plus petit
    scoredList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    stopwatch.stop();
    lastExecutionTimeMs = stopwatch.elapsedMilliseconds;
    
    // Debug info pour ta soutenance
    print("[Algo] Temps: ${lastExecutionTimeMs}ms. Top score: ${scoredList.first['score']}");

    return scoredList.take(20).map((e) => e['plat'] as Plat).toList();
  }
}

