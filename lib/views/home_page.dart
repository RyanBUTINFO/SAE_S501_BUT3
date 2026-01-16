import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Nécessaire pour le rangement
import 'package:shared_preferences/shared_preferences.dart'; // Nécessaire pour le rangement
import '../controllers/home_controller.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import 'infos_plat.dart';
import 'preferences_alimentaires_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance unique du repo pour éviter les ouvertures de base de données multiples
  final PlatRepository _repo = PlatRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageController>().loadData();
    });
  }

  // --- LOGIQUE DE RANGEMENT DANS LES DOSSIERS ---
  Future<void> _showFolderPicker(BuildContext context, Plat plat) async {
    final prefs = await SharedPreferences.getInstance();
    const String keyLists = "miaam_favorite_lists";
    final String? data = prefs.getString(keyLists);

    List<Map<String, dynamic>> favoriteLists = [];
    if (data != null) {
      favoriteLists = (jsonDecode(data) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              const Text("Ranger dans une liste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (favoriteLists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Vous n'avez pas encore de listes.\nCréez-en une dans l'onglet Favoris !", textAlign: TextAlign.center),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: favoriteLists.length,
                    itemBuilder: (context, index) {
                      final list = favoriteLists[index];
                      bool dejaPresent = list["plats"].contains(plat.id);

                      return ListTile(
                        leading: Icon(
                          dejaPresent ? Icons.check_circle : Icons.folder_open,
                          color: dejaPresent ? Colors.green : const Color(0xFF6B8E23),
                        ),
                        title: Text(list["name"], style: TextStyle(fontWeight: dejaPresent ? FontWeight.bold : FontWeight.normal)),
                        onTap: () async {
                          if (!dejaPresent) {
                            list["plats"].add(plat.id);
                            await prefs.setString(keyLists, jsonEncode(favoriteLists));
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Ajouté à : ${list["name"]}"), backgroundColor: const Color(0xFF6B8E23)),
                              );
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String? level) {
    final l = level?.toLowerCase() ?? "";
    if (l.contains("facile")) return const Color(0xFF6B8E23);
    if (l.contains("moyen")) return const Color(0xFFFFB300);
    if (l.contains("difficile")) return const Color(0xFFE57373);
    return const Color(0xFF6B8E23);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageController>();
    const Color greenMiaam = Color(0xFF6B8E23);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildModeSelector(controller),

              if (controller.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: CircularProgressIndicator(color: greenMiaam),
                ))
              else if (controller.currentPlats.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text("Aucune recette trouvée..."),
                ))
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(controller.isRecommendationMode 
                      ? "Recommandé pour vous ✨" 
                      : "Découvrir de nouvelles saveurs 🌍"),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: controller.currentPlats.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCardV1(context, controller.currentPlats[index], controller);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded( // Ajout de Expanded ici aussi par sécurité pour le texte
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello,", style: TextStyle(fontSize: 18, color: Colors.black54)),
                Text("What do you want\nto cook today?", 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 30, color: Color(0xFF6B8E23)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesAlimentairesPage())),
          )
        ],
      ),
    );
  }

  Widget _buildModeSelector(HomePageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            _modeButton("Découverte", !controller.isRecommendationMode, () => controller.setMode(false)),
            _modeButton("Pour vous", controller.isRecommendationMode, () => controller.setMode(true)),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6B8E23) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(label, textAlign: TextAlign.center, 
            style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRecipeCardV1(BuildContext context, Plat plat, HomePageController controller) {
    return GestureDetector(
      onTap: () async {
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CORRECTION ICI : Expanded assure que l'image prend l'espace restant ---
            Expanded(
              child: Stack(
                children: [
                  // Utilisation de Positioned.fill pour forcer l'image à respecter les limites
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.asset(
                        'assets/images_plats/${plat.id}.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        bool wasLiked = controller.isFavorite(plat.id);
                        controller.toggleFavorite(plat);
                        if (!wasLiked) {
                          _showFolderPicker(context, plat);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.isFavorite(plat.id) ? Icons.favorite : Icons.favorite_border,
                          color: controller.isFavorite(plat.id) ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop, size: 16, color: _getDifficultyColor(plat.cuisine)),
                      const SizedBox(width: 4),
                      // Flexible empêche le texte de déborder à droite s'il est trop long
                      Flexible(
                        child: Text(
                          plat.cuisine ?? "Facile",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _getDifficultyColor(plat.cuisine), 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
    );
  }
}