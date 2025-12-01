// lib/pages/recommendation_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/recommendation_controller.dart';
import '../models/plat.dart'; // OBLIGATOIRE

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  // CORRIGÉ : nom en minuscule + late
  late final PageController _pageController;
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();

    // Initialisation correcte
    _pageController = PageController();
    _timeStream = Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationController>().loadRecommendedPlats();
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
                StreamBuilder<DateTime>(
                  stream: _timeStream,
                  builder: (_, __) => Text(
                    TimeOfDay.now().format(context),
                    style: const TextStyle(color: Colors.black38, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
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

      body: Consumer<RecommendationController>(
        builder: (context, controller, _) {
          final List<Plat> plats = controller.recommendedPlats;

          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
          }

          if (plats.isEmpty) {
            return _buildEmptyState();
          }

          final carouselPlats = plats.take(3).toList();
          final gridPlats = plats.skip(3).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF6B8E23), size: 30),
                      const SizedBox(width: 12),
                      const Text(
                        "Recommandations pour vous",
                        style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF2E3B22)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B8E23)),
                        onPressed: () => controller.refresh(),
                        tooltip: "Rafraîchir",
                      ),
                    ],
                  ),
                ),

                // CARROUSEL
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController, // maintenant bien défini
                    itemCount: carouselPlats.length,
                    itemBuilder: (_, index) => _buildCarouselCard(carouselPlats[index], index),
                  ),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text("Autres idées qui pourraient vous plaire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: gridPlats.length,
                    itemBuilder: (_, index) => _buildGridCard(gridPlats[index]),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // === CARTES ===
  Widget _buildCarouselCard(Plat plat, int rank) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat', arguments: plat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF6B8E23), width: 3),
          image: DecorationImage(
            image: AssetImage(plat.image ?? 'assets/images/placeholder.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6B8E23).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 14,
              left: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  rank == 0 ? "Nº1 pour vous" : "Top ${rank + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B8E23)),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.title ?? plat.nom ?? "Délicieuse recette",
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black87, blurRadius: 8)]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.whatshot, size: 18, color: Colors.orangeAccent),
                      const SizedBox(width: 6),
                      Text(plat.level ?? "Moyen", style: const TextStyle(color: Colors.orangeAccent, fontSize: 14)),
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

  Widget _buildGridCard(Plat plat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat', arguments: plat),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6B8E23), width: 2),
          image: DecorationImage(
            image: AssetImage(plat.image ?? 'assets/images/placeholder.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.dstATop),
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFF6B8E23).withOpacity(0.12), blurRadius: 10),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.title ?? plat.nom ?? "Plat",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.water_drop, size: 16, color: Color(0xFF6B8E23)),
                      const SizedBox(width: 4),
                      Text(plat.level ?? "Moyen", style: const TextStyle(color: Color(0xFF6B8E23), fontSize: 13)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 90, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text("Pas encore de recommandations", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              "Aimez des recettes ou définissez vos préférences\npour des suggestions personnalisées !",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.read<RecommendationController>().refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    // Tu peux laisser ça pour plus tard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Menu paramètres bientôt disponible")),
    );
  }
}