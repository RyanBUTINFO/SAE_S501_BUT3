import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesAlimentairesPage extends StatefulWidget {
  const PreferencesAlimentairesPage({super.key});

  @override
  State<PreferencesAlimentairesPage> createState() => _PreferencesAlimentairesPageState();
}

class _PreferencesAlimentairesPageState extends State<PreferencesAlimentairesPage> {
  final Set<String> selectedCuisines = {};
  final Set<String> selectedDifficultes = {};
  final Set<String> selectedObjectifs = {};
  final List<String> avoidedIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  // 🔹 LIST SYNCHRONIZED WITH DB KEYS
  final List<String> cuisines = [
    'Français',
    'Italien',
    'Américain',
    'Mexicain',
    'Chinois',
    'Japonais',
    'Indien',
    'Espagnol',
    'Moyen-Orient',
    'Africain',
    'Asiatique'
  ];

  final List<String> difficultes = ['Facile', 'Moyen', 'Difficile'];
  final List<String> objectifs = ['Rapide (<30min)', 'Équilibré', 'Gourmand', 'Végétarien', 'Sans gluten', 'Faible en calories'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCuisines.clear(); selectedDifficultes.clear(); selectedObjectifs.clear(); avoidedIngredients.clear();
      if (prefs.getString('cuisines') != null) selectedCuisines.addAll(List<String>.from(jsonDecode(prefs.getString('cuisines')!)));
      if (prefs.getString('difficultes') != null) selectedDifficultes.addAll(List<String>.from(jsonDecode(prefs.getString('difficultes')!)));
      if (prefs.getString('objectifs') != null) selectedObjectifs.addAll(List<String>.from(jsonDecode(prefs.getString('objectifs')!)));
      if (prefs.getString('avoided_ingredients') != null) avoidedIngredients.addAll(List<String>.from(jsonDecode(prefs.getString('avoided_ingredients')!)));
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cuisines', jsonEncode(selectedCuisines.toList()));
    await prefs.setString('difficultes', jsonEncode(selectedDifficultes.toList()));
    await prefs.setString('objectifs', jsonEncode(selectedObjectifs.toList()));
    await prefs.setString('avoided_ingredients', jsonEncode(avoidedIngredients));
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Préférences enregistrées !"), backgroundColor: Color(0xFF6B8E23), duration: Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B8E23)), onPressed: () => Navigator.pop(context)), title: const Text("Préférences alimentaires", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 20)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildSection("Cuisine favorite"), _buildMultiChoiceChips(cuisines, selectedCuisines, (val) => setState(() => selectedCuisines.contains(val) ? selectedCuisines.remove(val) : selectedCuisines.add(val))),
            _buildSection("Niveau de difficulté"), _buildMultiChoiceChips(difficultes, selectedDifficultes, (val) => setState(() => selectedDifficultes.contains(val) ? selectedDifficultes.remove(val) : selectedDifficultes.add(val))),
            _buildSection("Objectif actuel"), _buildMultiChoiceChips(objectifs, selectedObjectifs, (val) => setState(() => selectedObjectifs.contains(val) ? selectedObjectifs.remove(val) : selectedObjectifs.add(val))),
            _buildSection("Ingrédients à éviter"), const SizedBox(height: 12), Row(children: [Expanded(child: TextField(controller: _ingredientController, decoration: InputDecoration(hintText: "Ex: arachide...", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), onSubmitted: (_) => _addIngredient())), const SizedBox(width: 12), FloatingActionButton.small(backgroundColor: const Color(0xFF6B8E23), onPressed: _addIngredient, child: const Icon(Icons.add, color: Colors.white))]), const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, children: avoidedIngredients.map((ing) => Chip(label: Text(ing), backgroundColor: Colors.red.shade100, deleteIconColor: Colors.red.shade700, onDeleted: () => setState(() => avoidedIngredients.remove(ing)))).toList()),
            const SizedBox(height: 50),
            // KEY FIX: async/await ensures save completes before pop
            SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async { await _savePreferences(); if (context.mounted) Navigator.pop(context, true); }, icon: const Icon(Icons.check_circle_outline), label: const Text("Enregistrer mes préférences", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E23), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 6))),
        ]),
      ),
    );
  }

  Widget _buildSection(String title) => Padding(padding: const EdgeInsets.only(top: 24, bottom: 12), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E3B22))));
  Widget _buildMultiChoiceChips(List<String> items, Set<String> selected, Function(String) onTap) => Wrap(spacing: 10, runSpacing: 10, children: items.map((item) => ChoiceChip(label: Text(item), selected: selected.contains(item), selectedColor: const Color(0xFF6B8E23), backgroundColor: const Color(0xFFE8F5E8), labelStyle: TextStyle(color: selected.contains(item) ? Colors.white : Colors.black87, fontWeight: selected.contains(item) ? FontWeight.bold : FontWeight.normal), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), onSelected: (_) => onTap(item))).toList());
  void _addIngredient() { if (_ingredientController.text.trim().isNotEmpty) setState(() { avoidedIngredients.add(_ingredientController.text.trim()); _ingredientController.clear(); }); }
}