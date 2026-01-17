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

  List<Plat> getBestMatches(List<Plat> allPlats, List<double> targetVector) {
    if (targetVector.isEmpty) return [];

    // --- DÉBUT DU MONITORING ---
    final stopwatch = Stopwatch()..start();

    // l'algo reste 100% identique ici
    List<Map<String, dynamic>> scoredList = allPlats.map((plat) {
      double score = calculateCosineSimilarity(targetVector, plat.vector);
      return {'plat': plat, 'score': score};
    }).toList();

    scoredList.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    // --- FIN DU MONITORING ---
    stopwatch.stop();
    lastExecutionTimeMs = stopwatch.elapsedMilliseconds;

    // Affichage pour un debug et les futurs rapports
    print("\n[SAÉ Performance] Temps: ${lastExecutionTimeMs}ms pour ${allPlats.length} plats");

    return scoredList.take(20).map((e) => e['plat'] as Plat).toList();
  }
}