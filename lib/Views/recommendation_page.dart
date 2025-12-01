// lib/Views/recommendation_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recommendation_controller.dart';
import '../models/plat.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});
  @override State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  late final Stream<DateTime> _timeStream;

  @override
  void initState() {
    super.initState();
    _timeStream = Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationController>().loadRecommendedPlats();
    });
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
                Image.asset('assets/images/logo.png', width: 32, height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23)),
                ),
                const SizedBox(width: 8),
                const Text("Miaam", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w700, fontSize: 22)),
                const Spacer(),
                StreamBuilder<DateTime>(
                  stream: _timeStream,
                  builder: (_, __) => Text(TimeOfDay.now().format(context), style: const TextStyle(color: Colors.black38, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF6B8E23), size: 26), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),

      body: Consumer<RecommendationController>(
        builder: (context, controller, _) {
          final plats = controller.recommendedPlats;
          if (controller.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6B8E23)));
          if (plats.isEmpty) return const Center(child: Text("Aucune recommandation"));

          final top3 = plats.take(3).toList();
          final others = plats.skip(3).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        _buildModeButton(label: 'Mode découverte', isActive: false, onPressed: () => Navigator.pop(context)),
                        const SizedBox(width: 8),
                        _buildModeButton(label: 'Mode recommandation', isActive: true, onPressed: () {}),
                      ],
                    ),
                  ),
                ),

                const Padding(padding: EdgeInsets.fromLTRB(24, 10, 24, 20), child: Text("Recommandations pour vous", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E3B22)))),

                ...top3.asMap().entries.map((e) => _buildTopCard(e.value, e.key + 1)),

                const SizedBox(height: 30),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text("Autres idées qui pourraient vous plaire", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.92,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: others.length,
                    itemBuilder: (_, i) => _buildGridCard(others[i]),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeButton({required String label, required bool isActive, required VoidCallback onPressed}) {
    return Expanded(
      child: StatefulBuilder(
        builder: (context, setState) {
          double opacity = 1.0;
          return GestureDetector(
            onTapDown: (_) => setState(() => opacity = 0.7),
            onTapUp: (_) => setState(() => opacity = 1.0),
            child: Opacity(
              opacity: opacity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? const Color(0xFF6B8E23) : const Color(0xFFE5EBE0),
                  foregroundColor: isActive ? Colors.white : const Color(0xFF6B8E23),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopCard(Plat plat, int rank) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat', arguments: plat),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFE8F5E8), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF6B8E23), width: 2.5)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("Nº$rank pour vous", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B8E23), fontSize: 13.5))),
                const SizedBox(height: 14),
                Text(plat.title ?? plat.nom ?? "Recette", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 22), const SizedBox(width: 8), Text("[Dinner]", style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600))]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(Plat plat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/infos_plat', arguments: plat),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFE8F5E8), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF6B8E23), width: 2.5)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(plat.title ?? plat.nom ?? "Plat inconnu", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 19, color: Color(0xFF6B8E23)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(plat.level ?? "Moyen", style: const TextStyle(color: Color(0xFF6B8E23), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}