import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/search_page_controller.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart'; // Import ajouté
import 'infos_plat.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fridgeController = TextEditingController();
  
  // On crée l'instance du repo ici pour l'utiliser dans la grille
  final PlatRepository _repo = PlatRepository();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SearchPageController>();
    const Color green = Color(0xFF6B8E23);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- SECTION MON FRIGO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🛒 Mon Frigo (Anti-Gaspillage)", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: green, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fridgeController,
                    onChanged: (v) => controller.updateIngredientSuggestions(v),
                    onSubmitted: (value) {
                      // Quand on appuie sur Entrer
                      if (controller.ingredientSuggestions.isNotEmpty) {
                        controller.addToFridge(controller.ingredientSuggestions[0]);
                        _fridgeController.clear();
                        controller.ingredientSuggestions = [];
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Ajouter un ingrédient...",
                      prefixIcon: const Icon(Icons.add_shopping_cart, size: 20),
                      filled: true, 
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15), 
                        borderSide: BorderSide.none
                      ),
                    ),
                  ),
                  if (controller.ingredientSuggestions.isNotEmpty)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]
                      ),
                      child: ListView.builder(
                        itemCount: controller.ingredientSuggestions.length,
                        itemBuilder: (ctx, i) => ListTile(
                          title: Text(controller.ingredientSuggestions[i]['nom']),
                          onTap: () {
                            controller.addToFridge(controller.ingredientSuggestions[i]);
                            _fridgeController.clear();
                            controller.ingredientSuggestions = [];
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: controller.fridgeIngredients.map((ing) => Chip(
                      label: Text(ing['nom'], style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: green,
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                      onDeleted: () => controller.removeFromFridge(ing['id']),
                    )).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 30),

            // --- RECHERCHE CLASSIQUE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => controller.setQuery(value),
                decoration: InputDecoration(
                  hintText: 'Ou chercher un nom de plat...',
                  prefixIcon: const Icon(Icons.search, color: green),
                  filled: true, 
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), 
                    borderSide: BorderSide.none
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.tune, color: _showFilters ? Colors.red : green),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                ),
              ),
            ),

            if (_showFilters) _buildAdvancedFilters(controller),

            // --- GRILLE DE RÉSULTATS ---
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator(color: green))
                  : _buildResultsGrid(controller.results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters(SearchPageController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Difficulté", style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: ["Facile", "Moyen", "Difficile"].map((diff) => FilterChip(
              label: Text(diff),
              selected: controller.selectedDifficulties.contains(diff),
              selectedColor: const Color(0xFF6B8E23).withOpacity(0.3),
              checkmarkColor: const Color(0xFF6B8E23),
              onSelected: (_) => controller.toggleFilter(controller.selectedDifficulties, diff),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(List<Plat> plats) {
    if (plats.isEmpty) {
      return const Center(
        child: Text("Ajoutez des ingrédients ou tapez un nom", 
          style: TextStyle(color: Colors.grey))
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 16, 
        childAspectRatio: 0.85
      ),
      itemCount: plats.length,
      itemBuilder: (context, index) {
        final plat = plats[index];
        return GestureDetector(
          onTap: () async {
            // --- ACTION CRUCIALE ---
            // On charge les ingrédients manquants avant d'ouvrir la page
            await _repo.hydraterIngredients(plat);
            
            if (context.mounted) {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => RecipePage(plat: plat))
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5EBE0), 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: const Color(0xFF6B8E23), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.asset(
                      'assets/images_plats/${plat.id}.webp', 
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    plat.nom, 
                    textAlign: TextAlign.center, 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}