
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PreferencesAlimentairesPage extends StatefulWidget {
  const PreferencesAlimentairesPage({super.key});

  @override
  State<PreferencesAlimentairesPage> createState() => _PreferencesAlimentairesPageState();
}

class _PreferencesAlimentairesPageState extends State<PreferencesAlimentairesPage> {
  // Listes de sélection (plusieurs choix possibles)
  final Set<String> selectedCuisines = {};
  final Set<String> selectedDifficultes = {};
  final Set<String> selectedObjectifs = {};
  final List<String> avoidedIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  // Options disponibles
  final List<String> cuisines = ['Française', 'Italienne', 'Asiatique', 'Indienne', 'Mexicaine', 'Méditerranéenne', 'Autre'];
  final List<String> difficultes = ['Facile', 'Moyen', 'Difficile'];
  final List<String> objectifs = ['Rapide (<30min)', 'Équilibré', 'Gourmand', 'Végétarien', 'Sans gluten', 'Faible en calories'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // CHARGEMENT des préférences au démarrage
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCuisines.clear();
      selectedDifficultes.clear();
      selectedObjectifs.clear();
      avoidedIngredients.clear();

      // Chargement des listes
      final cuisinesJson = prefs.getString('cuisines');
      final difficultesJson = prefs.getString('difficultes');
      final objectifsJson = prefs.getString('objectifs');
      final ingredientsJson = prefs.getString('avoided_ingredients');

      if (cuisinesJson != null) selectedCuisines.addAll(List<String>.from(jsonDecode(cuisinesJson)));
      if (difficultesJson != null) selectedDifficultes.addAll(List<String>.from(jsonDecode(difficultesJson)));
      if (objectifsJson != null) selectedObjectifs.addAll(List<String>.from(jsonDecode(objectifsJson)));
      if (ingredientsJson != null) avoidedIngredients.addAll(List<String>.from(jsonDecode(ingredientsJson)));
    });
  }

  // SAUVEGARDE des préférences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cuisines', jsonEncode(selectedCuisines.toList()));
    await prefs.setString('difficultes', jsonEncode(selectedDifficultes.toList()));
    await prefs.setString('objectifs', jsonEncode(selectedObjectifs.toList()));
    await prefs.setString('avoided_ingredients', jsonEncode(avoidedIngredients));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text("Préférences enregistrées !", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF6B8E23),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B8E23)), onPressed: () => Navigator.pop(context)),
        title: const Text("Préférences alimentaires", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Cuisine favorite"),
            _buildMultiChoiceChips(cuisines, selectedCuisines, (val) => setState(() => selectedCuisines.contains(val) ? selectedCuisines.remove(val) : selectedCuisines.add(val))),

            _buildSection("Niveau de difficulté"),
            _buildMultiChoiceChips(difficultes, selectedDifficultes, (val) => setState(() => selectedDifficultes.contains(val) ? selectedDifficultes.remove(val) : selectedDifficultes.add(val))),

            _buildSection("Objectif actuel"),
            _buildMultiChoiceChips(objectifs, selectedObjectifs, (val) => setState(() => selectedObjectifs.contains(val) ? selectedObjectifs.remove(val) : selectedObjectifs.add(val))),

            _buildSection("Ingrédients à éviter (allergies, goûts)"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: "Ex: arachide, lactose, coriandre...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (_) => _addIngredient(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  backgroundColor: const Color(0xFF6B8E23),
                  onPressed: _addIngredient,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: avoidedIngredients.map((ing) => Chip(
                label: Text(ing),
                backgroundColor: Colors.red.shade100,
                deleteIconColor: Colors.red.shade700,
                onDeleted: () => setState(() => avoidedIngredients.remove(ing)),
              )).toList(),
            ),

            const SizedBox(height: 50),

            // BOUTON ENREGISTRER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _savePreferences();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Enregistrer mes préférences", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E3B22))),
    );
  }

  Widget _buildMultiChoiceChips(List<String> items, Set<String> selected, Function(String) onTap) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => ChoiceChip(
        label: Text(item),
        selected: selected.contains(item),
        selectedColor: const Color(0xFF6B8E23),
        backgroundColor: const Color(0xFFE8F5E8),
        labelStyle: TextStyle(
          color: selected.contains(item) ? Colors.white : Colors.black87,
          fontWeight: selected.contains(item) ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onSelected: (_) => onTap(item),
      )).toList(),
    );
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isNotEmpty && !avoidedIngredients.contains(text)) {
      setState(() {
        avoidedIngredients.add(text);
        _ingredientController.clear();
      });
    }
  }
}