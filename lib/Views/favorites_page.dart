import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de la page
      backgroundColor: const Color(0xFFF6F8F4),

      // AppBar personnalisée avec logo, nom et heure
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Logo de l'application avec fallback si l'image n'existe pas
                Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.restaurant,
                    size: 32,
                    color: Color(0xFF6B8E23),
                  ),
                ),
                const SizedBox(width: 8),

                // Nom de l'application
                const Text(
                  "Miaam",
                  style: TextStyle(
                    color: Color(0xFF6B8E23),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),

                // Affichage de l'heure actuelle
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),

      // Contenu principal centré
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône coeur dans un cercle pour illustrer "pas de favoris"
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFF0F0), // Fond rose clair
                ),
                child: const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.redAccent,
                ),
              ),

              const SizedBox(height: 40), // Espacement vertical

              // Titre principal indiquant qu'il n'y a aucun favori
              const Text(
                'Aucune liste de favoris',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16), // Espacement vertical

              // Texte explicatif pour guider l'utilisateur
              const Text(
                'Créez des listes personnalisées pour organiser vos\nrecettes préférées.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40), // Espacement avant le bouton

              // Bouton pour créer la première liste
              ElevatedButton.icon(
                onPressed: () {
                  // Action lorsque l'utilisateur appuie sur le bouton
                  // Ici tu pourras ajouter la navigation vers l'écran de création de liste
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Créer ma première liste'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23), // Couleur verte
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: const StadiumBorder(), // Bouton arrondi
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
