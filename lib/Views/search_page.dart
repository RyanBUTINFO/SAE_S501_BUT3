import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Couleur de fond
      backgroundColor: const Color(0xFFF6F8F4),

      // AppBar personnalisée
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
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
                const Text(
                  "Miaam",
                  style: TextStyle(
                    color: Color(0xFF6B8E23),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),

      // Contenu principal avec défilement
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

            // Petit texte explicatif
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Tu peux rechercher une recette ou rechercher à partir d’ingrédients "poulet, courgettes"',
                style: TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Texte "OU"
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

            // Rangée de suggestions
            Row(
              children: const [
                Expanded(
                  child: _SuggestionCard(
                      title: 'Hiver',
                      image: 'assets/images/poulet_pate_cremeuse.jpg'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _SuggestionCard(
                      title: 'Citadin stressé',
                      image: 'assets/images/poulet_pate_cremeuse.jpg'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Zone résultats
            const Center(child: Text('Recherche')),
          ],
        ),
      ),
    );
  }
}

// Widget pour les cartes de suggestion
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String image;

  const _SuggestionCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.asset(image, fit: BoxFit.cover, height: 100),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
