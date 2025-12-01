import 'dart:async'; // Pour le flux de l'heure (Stream)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS DU PROJET ---
import 'search_page.dart';     
import 'favorites_page.dart'; 
import '../controllers/home_page_controller.dart'; 
// Note: On n'importe PAS le Repository ni le Modèle ici. 
// La Vue ne parle qu'au Contrôleur.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- GESTION D'ÉTAT UI (USER INTERFACE) ---
  
  // Contrôleur pour le défilement horizontal (Carrousel)
  final PageController _pageController = PageController();
  
  // Flux de données pour l'heure (mise à jour chaque minute sans recharger toute la page)
  late final Stream<DateTime> _timeStream;

  // --- CYCLE DE VIE DU WIDGET ---

  @override
  void initState() {
    super.initState();
    
    // 1. Lancement du chronomètre pour l'heure
    _timeStream = Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());

    // 2. Appel initial des données via le Contrôleur
    // addPostFrameCallback garantit que l'interface est prête avant de lancer la requête
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // On demande au contrôleur de charger 10 plats aléatoires
      context.read<HomePageController>().loadRandomPlats();
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Nettoyage pour éviter les fuites de mémoire
    super.dispose();
  }

  // --- CONSTRUCTION DE L'INTERFACE (BUILD) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      
      // 1. EN-TÊTE (APP BAR)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png', 
                  width: 32, height: 32,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23)),
                ),
                const SizedBox(width: 8),
                
                // Titre
                const Text(
                  "Miaam",
                  style: TextStyle(
                    color: Color(0xFF6B8E23),
                    fontWeight: FontWeight.w700,
                    fontSize: 22
                  ),
                ),
                
                const Spacer(), // Pousse les éléments suivants vers la droite
                
                // Heure dynamique (Optimisée avec StreamBuilder)
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
                
                // Bouton Paramètres
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Color(0xFF6B8E23), size: 26),
                  onPressed: () => _showSettingsMenu(context),
                  tooltip: 'Paramètres',
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. CORPS DE LA PAGE (Connecté au Contrôleur)
      // Le Consumer écoute les changements dans HomePageController et reconstruit l'UI si nécessaire
      body: Consumer<HomePageController>(
        builder: (context, controller, child) {
          
          // --- LOGIQUE D'AFFICHAGE ---
          // Le contrôleur renvoie une liste de 10 plats aléatoires.
          // On divise cette liste en deux parties pour l'interface :
          
          // Partie 1 : Les 3 premiers plats vont dans le Carrousel (Recettes du jour)
          final carouselPlats = controller.randomPlats.take(3).toList(); 
          
          // Partie 2 : Les 7 suivants vont dans la Grille (Top recettes)
          final gridPlats = controller.randomPlats.skip(3).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // A. SÉLECTEUR DE MODE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        _buildModeButton(
                          label: 'Mode découverte',
                          onPressed: () {
                            // Action : Demander au contrôleur de recharger de nouvelles données aléatoires
                            controller.loadRandomPlats();
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildModeButton(
                          label: 'Mode recommandation',
                          onPressed: () {
                            // TODO: Implémenter la logique future pour les recommandations
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // B. CARROUSEL (Partie supérieure)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 180,
                        // Gestion des états : Chargement, Vide, ou Affichage
                        child: controller.isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)))
                            : carouselPlats.isEmpty
                                ? const Center(child: Text("Chargement des recettes..."))
                                : PageView.builder(
                                    controller: _pageController,
                                    itemCount: carouselPlats.length,
                                    itemBuilder: (context, index) {
                                      final plat = carouselPlats[index];
                                      return recipeCard(
                                        // Mapping des données du modèle Plat vers le Widget
                                        image: plat.image ?? 'assets/images/placeholder.png', 
                                        title: plat.title ?? 'Sans titre',
                                        level: plat.level ?? 'Moyen',
                                        badge: 'Recette du jour',
                                        context: context, 
                                      );
                                    },
                                  ),
                      ),
                      // Flèches de navigation (masquées pendant le chargement)
                      if (!controller.isLoading && carouselPlats.isNotEmpty) ...[
                        Positioned(
                          left: -5,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, size: 39, color: Color(0xFF6B8E23)),
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 500), curve: Curves.ease
                            ),
                          ),
                        ),
                        Positioned(
                          right: -5,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, size: 39, color: Color(0xFF6B8E23)),
                            onPressed: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 500), curve: Curves.ease
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                
                // Titre Grille
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Text(
                    "Les top recettes",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
                
                // C. GRILLE (Partie inférieure)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: controller.isLoading
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ))
                      : gridPlats.isEmpty
                          ? const Center(child: Text("Aucune autre recette disponible"))
                          : GridView.count(
                              shrinkWrap: true, // Important : permet le scroll dans la Column parente
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.90,
                              children: gridPlats.map((plat) {
                                return gridRecipeCard(
                                  // Mapping des données du modèle Plat vers le Widget
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
            ),
          );
        },
      ),
      // bottomNavigationBar supprimée
    );
  }

  // ===========================================================================
  // WIDGETS D'AIDE (HELPERS) - Pour garder le code principal propre
  // ===========================================================================

  /// Crée un bouton de mode (Découverte/Recommandation).
  /// [IMPORTANT] : Utilise `mouseCursor` pour forcer le curseur "Main" au survol.
  Widget _buildModeButton({required String label, required VoidCallback onPressed}) {
    return Expanded(
      child: StatefulBuilder(
        builder: (context, setState) {
          double opacity = 1.0;
          return GestureDetector(
            // Animation d'opacité au clic
            onTapDown: (_) => setState(() => opacity = 0.7),
            onTapUp: (_) => setState(() => opacity = 1.0),
            onTapCancel: () => setState(() => opacity = 1.0),
            child: Opacity(
              opacity: opacity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFE5EBE0),
                  foregroundColor: const Color(0xFF6B8E23),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ).copyWith(
                  // C'est ici que l'on force le curseur en forme de main
                  mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          );
        },
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
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: const [
                  Icon(Icons.settings, color: Color(0xFF6B8E23), size: 28),
                  SizedBox(width: 10),
                  Text(
                    'Paramètres',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B8E23)),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Liste des options
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: Color(0xFF6B8E23)),
              title: const Text('Notifications'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Color(0xFF6B8E23)),
              title: const Text('Préférences alimentaires'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
             ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF6B8E23)),
              title: const Text('Langue'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
             ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF6B8E23)),
              title: const Text('Aide & Support'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.pop(context),
            ),
            // Option À propos (Ouvre une boîte de dialogue native)
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF6B8E23)),
              title: const Text('À propos'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.pop(context); // Fermer le menu
                showAboutDialog(
                  context: context,
                  applicationName: 'Miaam',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 Miaam Inc.',
                  applicationIcon: Image.asset(
                    'assets/images/logo.png', 
                    width: 40,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.restaurant, color: Color(0xFF6B8E23)),
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text("L'application idéale pour trouver des recettes délicieuses en un clic."),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Design de la carte pour le Carrousel (Grande taille)
  Widget recipeCard({
    required String image, 
    required String title, 
    required String level, 
    String? badge, 
    required BuildContext context
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6B8E23), width: 3),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {}, // Gestion d'erreur d'image silencieuse
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
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 2)]
                    )
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 17, color: Colors.orange.shade400),
                      Text(' $level',
                          style: TextStyle(color: Colors.orange.shade400, fontSize: 14)),
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

  /// Design de la carte pour la Grille (Petite taille)
  Widget gridRecipeCard({
    required String image, 
    required String title, 
    required String level, 
    required BuildContext context
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF6B8E23), width: 2),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.65), 
              BlendMode.dstATop
            ),
            onError: (exception, stackTrace) {},
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B8E23).withOpacity(0.10), 
              blurRadius: 10
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 17,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15
                    )
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 16, color: Color(0xFF6B8E23)),
                      Text(' $level',
                          style: const TextStyle(
                              color: Color(0xFF6B8E23), fontSize: 13)),
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