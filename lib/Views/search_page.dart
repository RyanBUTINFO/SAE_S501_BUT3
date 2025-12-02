import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/search_page_controller.dart';
import '../models/plat.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SearchPageController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 32, height: 32),
                const SizedBox(width: 8),
                const Text("Miaam",
                    style: TextStyle(color: Color(0xFF6B8E23),
                        fontWeight: FontWeight.w700,
                        fontSize: 22)),
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

          // BARRE DE RECHERCHE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<SearchPageController>().search(value);
              },
              decoration: InputDecoration(
                hintText: 'Une recette, des ingrédients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune, color: Color(0xFF6B8E23)),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          _showFilters ? _buildAdvancedFilters() : _buildResults(controller),
        ],
      ),
    );
  }

  // 🔥 Résultats / suggestions
  Widget _buildResults(SearchPageController controller) {
    if (controller.isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
        ),
      );
    }

    // Suggestion si champ vide
    if (_searchController.text.isEmpty) {
      return Expanded(
        child: Column(
          children: [
            const Text("Suggestions",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
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

    // Aucun résultat
    if (controller.results.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.black26),
              SizedBox(height: 10),
              Text("Aucune recette trouvée",
                  style: TextStyle(color: Colors.black45)),
            ],
          ),
        ),
      );
    }

    // Résultats filtrés
    return Expanded(
      child: Column(
        children: [
          Text('${controller.results.length} résultats trouvés',
              style: const TextStyle(color: Colors.black54)),
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
                    childAspectRatio: 1.55),
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
      ),
    );
  }

  // 🔥 Filtres avancés (entier)
  Widget _buildAdvancedFilters() {
    final controller = context.watch<SearchPageController>();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Filtres avancés",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showFilters = false),
                  ),
                ],
              ),
            ),
            const Divider(),

            // LISTE DES FILTRES
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _filterSection(
                      title: "Ingrédients",
                      icon: Icons.fastfood,
                      options: const ["Poulet", "Riz", "Tomates", "Oignons", "Carottes", "Pâtes", "Œufs", "Fromage"],
                      selectedSet: controller.selectedIngredients,
                    ),
                    _filterSection(
                      title: "Mode de cuisson",
                      icon: Icons.local_fire_department,
                      options: const ["Four", "Poêle", "Casserole", "Vapeur", "Friture", "Grill", "Cru"],
                      selectedSet: controller.selectedModes,
                    ),
                    _filterSection(
                      title: "Difficulté",
                      icon: Icons.bar_chart,
                      options: const ["Facile", "Moyen", "Difficile"],
                      selectedSet: controller.selectedDifficulties,
                    ),
                    _filterSection(
                      title: "Impact écologique",
                      icon: Icons.eco,
                      options: const ["Faible", "Moyen", "Élevé"],
                      selectedSet: controller.selectedImpacts,
                    ),
                  ],
                ),
              ),
            ),

            // Bouton reset
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E23),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: const Text("Réinitialiser les filtres",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Génération dynamique des filtres
  Widget _filterSection({
    required String title,
    required IconData icon,
    required List<String> options,
    required Set<String> selectedSet,
  }) {
    final controller = context.watch<SearchPageController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Icon(icon, color: Color(0xFF6B8E23)),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            return FilterChip(
              label: Text(opt),
              selected: selectedSet.contains(opt),
              onSelected: (_) =>
                  controller.toggleFilter(selectedSet, opt),
              selectedColor: const Color(0xFF6B8E23),
              labelStyle: TextStyle(
                color: selectedSet.contains(opt)
                    ? Colors.white
                    : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// 🔥 Carte suggestion (identique à ton code)
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String difficulty;
  const _SuggestionCard({required this.title, required this.difficulty});

  Color _getColor() {
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
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.water_drop, size: 20, color: _getColor()),
                const SizedBox(width: 6),
                Text(difficulty,
                    style: TextStyle(
                        color: _getColor(),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
