
import 'package:flutter/material.dart';

class PreferencesAlimentairesPage extends StatefulWidget {
  const PreferencesAlimentairesPage({super.key});

  @override
  State<PreferencesAlimentairesPage> createState() => _PreferencesAlimentairesPageState();
}

class _PreferencesAlimentairesPageState extends State<PreferencesAlimentairesPage> {
  String? selectedMealType;
  String? selectedCuisine;
  String? selectedDifficulty;
  String? selectedGoal;
  final List<String> avoidedIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  final List<String> mealTypes = ['Petit-déjeuner', 'Déjeuner', 'Dîner', 'Dessert', 'Snack'];
  final List<String> cuisines = ['Française', 'Italienne', 'Asiatique', 'Indienne', 'Mexicaine', 'Méditerranéenne', 'Autre'];
  final List<String> difficulties = ['Facile', 'Moyen', 'Difficile'];
  final List<String> goals = ['Rapide (<30min)', 'Équilibré', 'Gourmand', 'Végétarien', 'Sans gluten', 'Faible en calories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B8E23)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Préférences alimentaires",
          style: TextStyle(
            color: Color(0xFF6B8E23),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionTitle("Moment de la journée préféré"),
            _buildChips(mealTypes, selectedMealType, (val) => setState(() => selectedMealType = val)),

            _buildSectionTitle("Cuisine favorite"),
            _buildChips(cuisines, selectedCuisine, (val) => setState(() => selectedCuisine = val)),

            _buildSectionTitle("Niveau de difficulté"),
            _buildFilterChips(difficulties, selectedDifficulty, (val) => setState(() => selectedDifficulty = val)),

            _buildSectionTitle("Objectif actuel"),
            _buildChips(goals, selectedGoal, (val) => setState(() => selectedGoal = val)),

            _buildSectionTitle("Ingrédients à éviter (allergies, goûts)"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Ex: arachide, lactose, coriandre...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: _addAvoidedIngredient,
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  backgroundColor: const Color(0xFF6B8E23),
                  onPressed: () {
                    _addAvoidedIngredient(_ingredientController.text);
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: avoidedIngredients.map((ing) => Chip(
                label: Text(ing, style: const TextStyle(fontSize: 14)),
                backgroundColor: Colors.red.shade100,
                deleteIconColor: Colors.red.shade700,
                onDeleted: () => setState(() => avoidedIngredients.remove(ing)),
              )).toList(),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO : sauvegarder les préférences (SharedPreferences, Hive, Firebase...)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Préférences enregistrées avec succès !"),
                      backgroundColor: const Color(0xFF6B8E23),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E3B22)),
      ),
    );
  }

  Widget _buildChips(List<String> items, String? selected, Function(String?) onSelected) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) => ChoiceChip(
        label: Text(item),
        selected: selected == item,
        selectedColor: const Color(0xFF6B8E23),
        backgroundColor: const Color(0xFFE8F5E8),
        labelStyle: TextStyle(
          color: selected == item ? Colors.white : Colors.black87,
          fontWeight: selected == item ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onSelected: (_) => onSelected(selected == item ? null : item),
      )).toList(),
    );
  }

  Widget _buildFilterChips(List<String> items, String? selected, Function(String?) onSelected) {
    return Wrap(
      spacing: 12,
      children: items.map((item) => FilterChip(
        label: Text(item),
        selected: selected == item,
        selectedColor: const Color(0xFF6B8E23),
        checkmarkColor: Colors.white,
        backgroundColor: const Color(0xFFE8F5E8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onSelected: (_) => onSelected(selected == item ? null : item),
      )).toList(),
    );
  }

  void _addAvoidedIngredient(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty && !avoidedIngredients.contains(trimmed)) {
      setState(() {
        avoidedIngredients.add(trimmed);
        _ingredientController.clear();
      });
    }
  }
}