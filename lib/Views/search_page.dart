import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond de la page
      backgroundColor: const Color(0xFFF6F8F4),

      // AppBar personnalisée avec hauteur fixe
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

      // Contenu principal avec scroll pour éviter débordement clavier ou écran petit
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Champ de recherche avec style personnalisé
            TextField(
              decoration: InputDecoration(
                hintText: 'Une recette, des ingrédients...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFE5EBE0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Petit texte explicatif sous le champ de recherche
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tu peux rechercher une recette ou rechercher à partir d’ingrédients "poulet, courgettes"',
                style: TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Texte "OU" pour séparer les sections de recherche
            const Text(
              'OU',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Rangée de suggestions (cartes)
            Row(
              children: const [
                // Carte suggestion "Hiver"
                Expanded(
                  child: _SuggestionCard(
                      title: 'Hiver',
                      image: 'assets/images/poulet_pate_cremeuse.jpg'),
                ),
                SizedBox(width: 12),

                // Carte suggestion "Citadin stressé"
                Expanded(
                  child: _SuggestionCard(
                      title: 'Citadin stressé',
                      image: 'assets/images/poulet_pate_cremeuse.jpg'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Zone des résultats ou messages de recherche
            const Center(child: Text('Recherche')),
          ],
        ),
      ),
    );
  }
}

// Widget pour les cartes de suggestion avec gradient et texte sur l'image
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String image;

  const _SuggestionCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de la carte
          Image.asset(image, fit: BoxFit.cover),

          // Gradient pour lisibilité du texte
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),

          // Texte du titre aligné en bas à gauche
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
