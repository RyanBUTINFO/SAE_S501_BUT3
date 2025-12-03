import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS DU PROJET ---
import 'search_page.dart';
import 'favorites_page.dart';
import 'preferences_alimentaires_page.dart';
import '../controllers/home_page_controller.dart';
import '../models/plat.dart'; // Import nécessaire pour le modèle Plat
import 'infos_plat.dart'; // Assurez-vous que cette page existe

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());

    // Charger les données dès l'ouverture de l'app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageController>().loadData();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23)),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Miaam",
                  style: TextStyle(
                      color: Color(0xFF6B8E23),
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
                const Spacer(),
                StreamBuilder<DateTime>(
                  stream: _timeStream,
                  builder: (context, snapshot) {
                    final now = TimeOfDay.now();
                    return Text(
                      now.format(context),
                      style: const TextStyle(color: Colors.black38, fontSize: 14),
                    );
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Color(0xFF6B8E23), size: 26),
                  onPressed: () => _showSettingsMenu(context),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- BODY ---
      body: Consumer<HomePageController>(
        builder: (context, controller, child) {
          final plats = controller.currentPlats;
          final carouselPlats = plats.length >= 3 ? plats.take(3).toList() : plats;
          final gridPlats = plats.length > 3 ? plats.skip(3).toList() : [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SWITCH MODE BUTTONS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        _buildModeButton(
                          label: 'Mode découverte',
                          isActive: !controller.isRecommendationMode,
                          onPressed: () => controller.setMode(false),
                        ),
                        const SizedBox(width: 8),
                        _buildModeButton(
                          label: 'Mode recommandation',
                          isActive: controller.isRecommendationMode,
                          onPressed: () => controller.setMode(true),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- CONTENT AREA ---
                if (controller.isLoading)
                  const SizedBox(
                    height: 400,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6B8E23))),
                  )
                else if (plats.isEmpty)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 40, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          const Text("Aucune recette trouvée"),
                          TextButton(
                            onPressed: () => controller.loadData(),
                            child: const Text("Réessayer", style: TextStyle(color: Color(0xFF6B8E23))),
                          )
                        ],
                      ),
                    ),
                  )
                else ...[
                  // --- CAROUSEL (Mise à jour pour passer l'objet plat) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: carouselPlats.length,
                            itemBuilder: (context, index) {
                              final plat = carouselPlats[index];
                              String badge = controller.isRecommendationMode
                                  ? "Top ${index + 1} pour vous"
                                  : "Recette du jour";
                              return recipeCard(
                                plat: plat, // Passons l'objet Plat
                                image: plat.image ?? 'assets/images/placeholder.png',
                                title: plat.title ?? 'Sans titre',
                                level: plat.level ?? 'Moyen',
                                badge: badge,
                                context: context,
                              );
                            },
                          ),
                          if (carouselPlats.length > 1) ...[
                            Positioned(
                              left: -5,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    size: 39, color: Color(0xFF6B8E23)),
                                onPressed: () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease),
                              ),
                            ),
                            Positioned(
                              right: -5,
                              child: IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    size: 39, color: Color(0xFF6B8E23)),
                                onPressed: () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // --- GRID TITLE ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    child: Text(
                      controller.isRecommendationMode
                          ? "Autres suggestions"
                          : "Les top recettes",
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ),

                  // --- GRID (Mise à jour pour passer l'objet plat) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: gridPlats.isEmpty
                        ? const Center(child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("C'est tout pour aujourd'hui !"),
                            ))
                        : GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.90,
                            children: gridPlats.map((plat) {
                              return gridRecipeCard(
                                plat: plat, // Passons l'objet Plat
                                image: plat.image ?? 'assets/images/placeholder.png',
                                title: plat.title ?? 'Sans titre',
                                level: plat.level ?? 'Non spécifié',
                                context: context,
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isActive ? const Color(0xFF6B8E23) : const Color(0xFFE5EBE0),
          foregroundColor: isActive ? Colors.white : const Color(0xFF6B8E23),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Affiche le menu "Paramètres" en bas de l'écran
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- EN-TÊTE DU MENU ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF6B8E23), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Paramètres',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E23)),
                  ),
                ],
              ),
            ),
            const Divider(),

            // --- 1. NOTIFICATIONS ---
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: Color(0xFF6B8E23)),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Les notifications sont activées !"),
                    backgroundColor: Color(0xFF6B8E23),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            // --- 2. PRÉFÉRENCES ALIMENTAIRES (Navigation réelle) ---
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Color(0xFF6B8E23)),
              title: const Text('Préférences alimentaires'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx); // Ferme le menu
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PreferencesAlimentairesPage()),
                );
              },
            ),

            // --- 3. LANGUE ---
            ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF6B8E23)),
              title: const Text('Langue'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx);
                _showLanguageDialog(context); // Ouvre une petite boite de dialogue
              },
            ),

            // --- 4. AIDE & SUPPORT ---
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF6B8E23)),
              title: const Text('Aide & Support'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(ctx);
                showAboutDialog(
                  context: context,
                  applicationName: 'Miaam',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Miaam Inc.',
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text("Besoin d'aide ? Contactez support@miaam.com"),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Petit bonus : Boite de dialogue pour le choix de langue ---
  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Choisir la langue"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Français"),
              leading: const Text("🇫🇷", style: TextStyle(fontSize: 20)),
              trailing: const Icon(Icons.check, color: Color(0xFF6B8E23)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              title: const Text("English"),
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 20)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              title: const Text("Español"),
              leading: const Text("🇪🇸", style: TextStyle(fontSize: 20)),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
  
  // *** WIDGET DE CARTE CORRIGÉ ***
  Widget recipeCard({
    required Plat plat, // Paramètre ajouté
    required String image,
    required String title,
    required String level,
    String? badge,
    required BuildContext context,
  }) {
    return GestureDetector(
      // CORRECTION: Appel du contrôleur pour la navigation
      onTap: () => context.read<HomePageController>().onPlatTapped(context, plat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6B8E23), width: 3),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (badge != null)
              Positioned(
                left: 20,
                top: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              bottom: 26,
              child: Container(
                // Ajout d'un petit fond sombre pour que le texte soit lisible sur toute image
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 17, color: Colors.orange.shade400),
                        Text(
                          ' $level',
                          style: TextStyle(
                              color: Colors.orange.shade400, 
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // *** WIDGET DE CARTE GRILLE CORRIGÉ ***
  Widget gridRecipeCard({
    required Plat plat, // Paramètre ajouté
    required String image,
    required String title,
    required String level,
    required BuildContext context,
  }) {
    return GestureDetector(
      // CORRECTION: Appel du contrôleur pour la navigation
      onTap: () => context.read<HomePageController>().onPlatTapped(context, plat),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF6B8E23), width: 2),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.65),
              BlendMode.dstATop,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.10),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 17,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 16, color: Color(0xFF6B8E23)),
                      Text(
                        ' $level',
                        style: const TextStyle(
                            color: Color(0xFF6B8E23), fontSize: 13),
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
}