import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/home_controller.dart';
import '../models/plat.dart';
import '../repositories/plat_repository.dart';
import 'infos_plat.dart'; 

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteLists = [];
  Map<String, dynamic>? selectedList;
  static const String _keyLists = "miaam_favorite_lists";
  
  // Contrôleur pour le texte du nouveau dossier
  final TextEditingController _listController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

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

  // --- SAUVEGARDE ---
  Future<void> _saveLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLists, jsonEncode(favoriteLists));
  }

  // --- CRÉATION DU DOSSIER ---
  void _addList() {
    if (_listController.text.isEmpty) return;
    setState(() {
      favoriteLists.add({
        "name": _listController.text,
        "plats": [] // Liste d'IDs vide au départ
      });
      _listController.clear();
    });
    _saveLists();
    Navigator.pop(context); // Ferme le popup
  }

  // --- POPUP DE CRÉATION ---
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle liste"),
        content: TextField(
          controller: _listController,
          decoration: const InputDecoration(hintText: "Ex: Idées déjeuner, Sport..."),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: _addList,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23)),
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      appBar: AppBar(
        title: Text(selectedList == null ? "Mes Listes" : selectedList!["name"],
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: selectedList != null 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), 
              onPressed: () => setState(() => selectedList = null))
          : null,
        actions: [
          // On n'affiche le bouton "+" que si on est sur l'écran des dossiers
          if (selectedList == null)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6B8E23), size: 30),
              onPressed: _showAddDialog,
            ),
        ],
      ),
      body: selectedList == null ? _buildListsGrid() : _buildListDetail(),
    );
  }

  Widget _buildListsGrid() {
    if (favoriteLists.isEmpty) {
      return const Center(
        child: Text("Appuyez sur + pour créer votre première liste !"),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteLists.length,
      itemBuilder: (context, index) {
        final list = favoriteLists[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.folder, color: Color(0xFF6B8E23), size: 30),
            title: Text(list["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${list["plats"].length} recettes"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                setState(() => favoriteLists.removeAt(index));
                _saveLists();
              },
            ),
            onTap: () async {
              await _loadLists(); 
              setState(() => selectedList = list);
            },
          ),
        );
      },
    );
  }

  Widget _buildListDetail() {
    final List<dynamic> idsDansDossier = selectedList!["plats"];

    if (idsDansDossier.isEmpty) {
      return const Center(child: Text("Dossier vide."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: idsDansDossier.length,
      itemBuilder: (context, index) {
        final int platId = idsDansDossier[index];

        return FutureBuilder<Plat?>(
          future: PlatRepository().getPlatById(platId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final plat = snapshot.data!;

            return Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images_plats/${plat.id}.webp', 
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => const Icon(Icons.restaurant)),
                ),
                title: Text(plat.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  await PlatRepository().hydraterIngredients(plat);
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RecipePage(plat: plat)));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}