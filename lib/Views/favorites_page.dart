// lib/Views/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteLists = [];
  Map<String, dynamic>? selectedList;
  final TextEditingController _controller = TextEditingController();

  static const String _keyLists = "miaam_favorite_lists";

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  // Charger les listes au démarrage
  Future<void> _loadLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyLists);
    if (data != null) {
      setState(() {
        favoriteLists = (jsonDecode(data) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    }
  }

  // Sauvegarder à chaque modification
  Future<void> _saveLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLists, jsonEncode(favoriteLists));
  }

  void _showCreateListDialog() {
    _controller.clear();
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
              final name = _controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  favoriteLists.add({"name": name, "recipes": <String>[]});
                });
                _saveLists();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Liste « $name » créée !"), backgroundColor: const Color(0xFF6B8E23)),
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

  void _deleteList(int index) {
    setState(() {
      favoriteLists.removeAt(index);
      if (favoriteLists.isEmpty) selectedList = null;
    });
    _saveLists();
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

      body: favoriteLists.isEmpty
          ? _buildEmptyState()
          : selectedList != null
              ? _buildListDetail()
              : _buildListsOverview(),

      floatingActionButton: favoriteLists.isNotEmpty && selectedList == null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF6B8E23),
              onPressed: _showCreateListDialog,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 120, height: 120, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFF0F0)), child: const Icon(Icons.favorite, size: 70, color: Colors.redAccent)),
            const SizedBox(height: 40),
            const Text("Aucune liste de favoris", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Créez des listes personnalisées pour organiser vos\nrecettes préférées.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _showCreateListDialog,
              icon: const Icon(Icons.add),
              label: const Text("Créer ma première liste"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18), shape: const StadiumBorder()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListsOverview() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteLists.length,
      itemBuilder: (context, index) {
        final list = favoriteLists[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFFFFF5F5),
          child: ListTile(
            leading: const Icon(Icons.bookmark_border, color: Color(0xFF6B8E23)),
            title: Text(list["name"], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text("${list["recipes"].length} recettes"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteList(index)),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
            onTap: () => setState(() => selectedList = list),
          ),
        );
      },
    );
  }

  Widget _buildListDetail() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF6B8E23)), onPressed: () => setState(() => selectedList = null))),
          const SizedBox(height: 20),
          Text(selectedList!["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          const Text("Aucune recette pour le moment", style: TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text("Parcourir les recettes", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 17)),
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