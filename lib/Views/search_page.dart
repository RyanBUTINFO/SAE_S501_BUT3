// lib/Views/search_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/search_page_controller.dart'; // Import du contrôleur
import '../models/plat.dart'; // Import du modèle

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _showFilters = false;
  
  // AJOUT : Contrôleur pour le champ de texte
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      body: Column(
        children: [
          const SizedBox(height: 12),

          // Barre de recherche + bouton filtre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController, // AJOUT : Connexion au contrôleur de texte
              onChanged: (value) {
                // AJOUT : Appel de la recherche dynamique
                context.read<SearchPageController>().search(value);
                setState(() {}); // Rafraichir pour basculer entre suggestions et résultats
              },
              decoration: InputDecoration(
                hintText: 'Une recette, des ingrédients...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFF6B8E23)),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // === FILTRE AVANCÉ OU GRILLE DYNAMIQUE ===
          if (_showFilters)
            _buildAdvancedFilters()
          else
            // AJOUT : Consumer pour écouter les résultats de la recherche
            Expanded(
              child: Consumer<SearchPageController>(
                builder: (context, controller, child) {
                  
                  // 1. CAS CHARGEMENT
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
                  }

                  // 2. CAS RECHERCHE VIDE -> AFFICHER VOTRE CONTENU ORIGINAL (Suggestions)
                  if (_searchController.text.isEmpty) {
                    return Column(
                      children: [
                        const Text('Suggestions', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.55,
                              // VOS CARTES STATIQUES ORIGINALES
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
                    );
                  }

                  // 3. CAS AUCUN RÉSULTAT TROUVÉ
                  if (controller.results.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.black26),
                          SizedBox(height: 10),
                          Text("Aucune recette trouvée", style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    );
                  }

                  // 4. CAS RÉSULTATS DYNAMIQUES (Base de données)
                  return Column(
                    children: [
                      Text('${controller.results.length} résultats trouvés', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.builder(
                            itemCount: controller.results.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.55,
                            ),
                            itemBuilder: (context, index) {
                              final Plat plat = controller.results[index];
                              return _SuggestionCard(
                                title: plat.title ?? "Nom inconnu",
                                difficulty: plat.level ?? "Moyen",
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Filtres avancés – sans overflow (VOTRE CODE ORIGINAL CONSERVÉ)
  Widget _buildAdvancedFilters() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filtres avancés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => setState(() => _showFilters = false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterSection("Ingrédients", Icons.fastfood, ["Poulet", "Riz", "Tomates", "Oignons", "Carottes", "Pâtes", "Œufs", "Fromage"]),
                    _filterSection("Mode de cuisson", Icons.local_fire_department, ["Four", "Poêle", "Casserole", "Vapeur", "Friture", "Grill", "Cru"]),
                    _filterSection("Difficulté", Icons.bar_chart, ["Facile", "Moyen", "Difficile"]),
                    _filterSection("Impact écologique", Icons.eco, ["Faible", "Moyen", "Élevé"]),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _showFilters = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B8E23),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Réinitialiser les filtres", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSection(String title, IconData icon, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6B8E23), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) => FilterChip(
            label: Text(opt),
            selected: false,
            onSelected: (_) {},
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF6B8E23),
            labelStyle: const TextStyle(fontSize: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.transparent),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

// Widget pour les cartes de suggestion avec fond clair + goutte difficulté
// (VOTRE CODE ORIGINAL CONSERVÉ)
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String difficulty;
  const _SuggestionCard({required this.title, required this.difficulty});

  Color _getColor() {
    // Normalisation pour matcher les données de la DB ou statiques
    final level = difficulty.trim().toLowerCase();
    if (level.contains("facile")) return const Color(0xFF6B8E23);
    if (level.contains("moyen")) return const Color(0xFFFFB300);
    if (level.contains("difficile")) return const Color(0xFFE57373);
    return const Color(0xFF6B8E23);
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
            ),
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
