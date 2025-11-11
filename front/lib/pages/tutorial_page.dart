import 'package:flutter/material.dart';
import 'video_page.dart'; // Ajoute cet import

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Bienvenue sur miaam !',
                style: TextStyle(
                  color: Color(0xFF6B8E23),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  "Découvrez comment utiliser l'application pour réduire votre gaspillage alimentaire et trouver des recettes adaptées à vos ingrédients.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 320,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6EB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF6B8E23),
                      size: 80,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tutoriel vidéo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E23),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Regardez cette courte vidéo pour comprendre comment fonctionne miaam",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VideoPage()),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Voir le tutoriel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E23),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () {
                  // Ajoute la logique pour aller à la page suivante si besoin.
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6B8E23)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    "Commencer à utiliser miaam",
                    style: TextStyle(color: Color(0xFF6B8E23)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
