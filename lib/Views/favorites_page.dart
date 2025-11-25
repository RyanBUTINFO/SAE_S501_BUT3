// lib/Views/favorites_page.dart
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // true = état vide avec  cœur (premier écran)
  // false = on a au moins une liste (écran avec cartes)
  bool _isEmpty = true;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),

      // === APPBAR MIAAM (identique aux autres pages) ===
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

      
      body: _isEmpty ? _buildEmptyState() : _buildListState(),
    );
  }

  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //cœur rose
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF0F0),
              ),
              child: const Icon(Icons.favorite, size: 70, color: Colors.redAccent),
            ),
            const SizedBox(height: 40),

            const Text(
              "Aucune liste de favoris",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Créez des listes personnalisées pour organiser vos\nrecettes préférées.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 40),

            //bouton vert (clic → ouvre la modale)
            ElevatedButton.icon(
              onPressed: _showCreateListDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Créer ma première liste", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E23),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: const StadiumBorder(),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modale "Nouvelle liste de favoris"
  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Nouvelle liste de favoris", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: "Nom de la liste (ex: Desserts, Repas rapides...)",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                setState(() => _isEmpty = false); // passe à l’état IMAGE 3
                _controller.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Liste créée !"), backgroundColor: Color(0xFF6B8E23)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
            child: const Text("Créer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //État avec une liste + "Parcourir les recettes"
  Widget _buildListState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Carte de la liste créée
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.bookmark_border, color: Color(0xFF6B8E23), size: 32),
              title: Text(_controller.text.isEmpty ? "Ma liste" : _controller.text, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("0 recettes"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
          const SizedBox(height: 40),

          // Texte gris centré
          const Text("Aucune recette pour le moment", style: TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 20),

          // Bouton "Parcourir les recettes" vert
          TextButton(
            onPressed: () {
              // Retour à l'accueil
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              "Parcourir les recettes",
              style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}