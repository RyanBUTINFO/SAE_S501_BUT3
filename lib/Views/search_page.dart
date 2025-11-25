// lib/Views/search_page.dart
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23)),
                ),
                const SizedBox(width: 8),
                const Text("Miaam", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w700, fontSize: 22)),
                const Spacer(),
                Text(TimeOfDay.now().format(context), style: const TextStyle(color: Colors.black38)),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Une recette, des ingrédients...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFE5EBE0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Tu peux rechercher une recette ou rechercher à partir d’ingrédients "poulet, courgettes"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),

          const SizedBox(height: 16),
          const Text('OU', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500)),

          const SizedBox(height: 24),

          // ← LA GRILLE PARFAITE (remplace ton Row cassé)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.55,
                children: const [
                  _SuggestionCard(title: "Crêpes sucrées parfait", difficulty: "Facile"),
                  _SuggestionCard(title: "Tiramisu traditionnel", difficulty: "Difficile"),
                  _SuggestionCard(title: "Lasagnes végétales", difficulty: "Moyen"),
                  _SuggestionCard(title: "Smoothie détox vert", difficulty: "Facile"),
                  _SuggestionCard(title: "Brioche feuilletée", difficulty: "Difficile"),
                  _SuggestionCard(title: "Bowl de quinoa épicé", difficulty: "Facile"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Carte finale EXACTEMENT comme ton mockup (fond clair, bordure verte, goutte couleur)
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String difficulty;

  const _SuggestionCard({required this.title, required this.difficulty});

  Color _getColor() {
    switch (difficulty) {
      case "Facile": return const Color(0xFF6B8E23);
      case "Moyen": return const Color(0xFFFFB300);
      case "Difficile": return const Color(0xFFE57373);
      default: return const Color(0xFF6B8E23);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EBE0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6B8E23), width: 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.water_drop, size: 20, color: _getColor()),
                const SizedBox(width: 6),
                Text(difficulty, style: TextStyle(color: _getColor(), fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}