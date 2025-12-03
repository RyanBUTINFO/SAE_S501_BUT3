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
  void initState() {
    super.initState();
    // Synchroniser le champ texte avec le contrôleur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.text = context.read<SearchPageController>().currentQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      // --- APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 32, height: 32,
                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23))),
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

          // --- BARRE DE RECHERCHE ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<SearchPageController>().setQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Une recette, des ingrédients...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: IconButton(
                  // L'icône change de couleur si le panneau filtre est ouvert
                  icon: Icon(Icons.tune, color: _showFilters ? const Color(0xFFE57373) : const Color(0xFF6B8E23)),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // --- CONTENU PRINCIPAL ---
          if (_showFilters)
            _buildAdvancedFilters() // Affiche le panneau de filtres
          else
            _buildSearchResults(),  // Affiche les résultats ou suggestions
        ],
      ),
    );
  }

  // --- PANNEAU DES RÉSULTATS ---
  Widget _buildSearchResults() {
    return Expanded(
      child: Consumer<SearchPageController>(
        builder: (context, controller, child) {
          
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
          }

          // Si rien n'est recherché, afficher les suggestions statiques
          if (controller.currentQuery.isEmpty && 
              controller.selectedDifficulties.isEmpty && 
              controller.selectedIngredients.isEmpty &&
              controller.selectedCookingModes.isEmpty) {
            return _buildStaticSuggestions();
          }

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

          // Grille des résultats trouvés
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
                      childAspectRatio: 0.8, // Ratio ajusté pour bien voir les cartes
                    ),
                    itemBuilder: (context, index) {
                      final Plat plat = controller.results[index];
                      return _SuggestionCard(
                        title: plat.title ?? "Nom inconnu",
                        difficulty: plat.level ?? "Moyen",
                        imagePath: plat.image, // On passe l'image si dispo
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- PANNEAU DES FILTRES (CORRIGÉ) ---
  Widget _buildAdvancedFilters() {
    return Expanded(
      child: Consumer<SearchPageController>(
        builder: (context, controller, child) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                // En-tête
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

                // Liste des catégories de filtres
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // 1. Ingrédients (Connecté au controller)
                        _filterSection(
                          "Ingrédients", Icons.fastfood,
                          ["Poulet", "Riz", "Tomates", "Oignons", "Carottes", "Pâtes", "Œufs", "Fromage", "Champignons"],
                          controller.selectedIngredients, // La liste active
                          (val) => controller.toggleFilter(controller.selectedIngredients, val), // L'action
                        ),

                        // 2. Mode de cuisson (Connecté au controller)
                        _filterSection(
                          "Mode de cuisson", Icons.local_fire_department,
                          ["Four", "Poêle", "Casserole", "Vapeur", "Friture", "Wok"],
                          controller.selectedCookingModes,
                          (val) => controller.toggleFilter(controller.selectedCookingModes, val),
                        ),

                        // 3. Difficulté (Connecté au controller)
                        _filterSection(
                          "Difficulté", Icons.bar_chart,
                          ["Facile", "Moyen", "Difficile"],
                          controller.selectedDifficulties,
                          (val) => controller.toggleFilter(controller.selectedDifficulties, val),
                        ),
                        
                        // 4. Impact (Visuel uniquement pour l'instant)
                        _filterSection(
                          "Impact écologique", Icons.eco,
                          ["Faible", "Moyen", "Élevé"],
                          controller.selectedEcoImpacts,
                          (val) => controller.toggleFilter(controller.selectedEcoImpacts, val),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bouton Réinitialiser
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.resetFilters();
                        // Optionnel : fermer le panneau après reset
                        // setState(() => _showFilters = false);
                      },
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
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER POUR UNE SECTION DE FILTRE ---
  Widget _filterSection(
    String title, 
    IconData icon, 
    List<String> options, 
    List<String> selectedList, 
    Function(String) onToggle
  ) {
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
          children: options.map((opt) {
            final isSelected = selectedList.contains(opt);
            return FilterChip(
              label: Text(opt),
              selected: isSelected,
              onSelected: (_) => onToggle(opt), // C'est ici que le clic est détecté
              backgroundColor: Colors.grey[100],
              selectedColor: const Color(0xFF6B8E23), // Vert Kaki quand sélectionné
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET SUGGESTIONS PAR DÉFAUT ---
  Widget _buildStaticSuggestions() {
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
}

// --- CARTE DE RECETTE ---
class _SuggestionCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final String? imagePath; // Optionnel

  const _SuggestionCard({required this.title, required this.difficulty, this.imagePath});

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
            Expanded(
              child: Text(
                title, 
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
              ),
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

