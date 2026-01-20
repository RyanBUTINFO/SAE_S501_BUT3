import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  final PlatRepository _repo = PlatRepository();
  
  // Palette de couleurs Modern Organic
  final Color kOliveColor = const Color(0xFF6B8E23);
  final Color kBgColor = const Color(0xFFFBFBFA);
  final Color kDeepGreen = const Color(0xFF2D3319);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageController>().loadData();
    });
  }

  // --- LOGIQUE DOSSIERS (GARDEE) ---
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
                          color: dejaPresent ? Colors.green : kOliveColor,
                        ),
                        title: Text(list["name"], style: TextStyle(fontWeight: dejaPresent ? FontWeight.bold : FontWeight.normal)),
                        onTap: () async {
                          if (!dejaPresent) {
                            list["plats"].add(plat.id);
                            await prefs.setString(keyLists, jsonEncode(favoriteLists));
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("📁 Ajouté à : ${list["name"]}"), backgroundColor: kOliveColor),
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomePageController>();

    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: CustomScrollView( // Plus fluide pour le scroll
          slivers: [
            // --- HEADER ---
            SliverToBoxAdapter(child: _buildHeader(context)),

            // --- SELECTOR ---
            SliverToBoxAdapter(child: _buildModeSelector(controller)),

            // --- CONTENU ---
            if (controller.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23))))
            else if (controller.currentPlats.isEmpty)
              const SliverFillRemaining(child: Center(child: Text("Aucune recette trouvée...")))
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                  child: Text(
                    controller.isRecommendationMode ? "Recommandé pour vous ✨" : "Découvrir de nouvelles saveurs 🌍",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kDeepGreen),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 22,
                    childAspectRatio: 0.76,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildRecipeCardV2(context, controller.currentPlats[index], controller),
                    childCount: controller.currentPlats.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bonjour ! 👋", style: TextStyle(fontSize: 16, color: kDeepGreen.withOpacity(0.5))),
                const SizedBox(height: 4),
                Text("On sauve quoi\naujourd'hui ?", 
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kDeepGreen, height: 1.1, letterSpacing: -0.5)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
            child: IconButton(
              icon: Icon(Icons.settings_outlined, size: 24, color: kOliveColor),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesAlimentairesPage())),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModeSelector(HomePageController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? kOliveColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(label, textAlign: TextAlign.center, 
            style: TextStyle(color: active ? Colors.white : Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRecipeCardV2(BuildContext context, Plat plat, HomePageController controller) {
    bool isFav = controller.isFavorite(plat.id);
    
    return GestureDetector(
      onTap: () async {
        await _repo.hydraterIngredients(plat);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RecipePage(plat: plat)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images_plats/${plat.id}.webp',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  // Boutons Flottants
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => controller.toggleFavorite(plat),
                          child: _circleIcon(isFav ? Icons.favorite : Icons.favorite_border, isFav ? Colors.red : kOliveColor),
                        ),
                        if (isFav) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showFolderPicker(context, plat),
                            child: _circleIcon(Icons.folder_open, kOliveColor),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kDeepGreen),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text("15 min", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Text("🌿", style: TextStyle(fontSize: 12)),
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

  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}