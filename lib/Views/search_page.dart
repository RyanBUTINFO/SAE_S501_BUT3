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
                // Logo de l'application
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

      // Contenu principal de la page
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Champ de recherche
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

            // Zone où les résultats ou messages apparaîtront
            const Center(child: Text('Recherche')),
          ],
        ),
      ),
    );
  }
}
