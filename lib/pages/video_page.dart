import 'package:flutter/material.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vidéo de démonstration',
              style: TextStyle(
                color: Color(0xFF6B8E23),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lecture du tutoriel vidéo...")),
                );
                // À remplacer plus tard par un vrai lecteur vidéo
              },
              child: Container(
                width: 350,
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0xFF232A32),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Color(0xFF6B8E23),
                    size: 64,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "La vidéo vous montre comment rechercher des recettes, utiliser les filtres et sauvegarder vos favoris",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
