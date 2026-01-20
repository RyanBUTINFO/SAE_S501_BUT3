import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plat.dart';
import '../controllers/home_controller.dart';

class RecipePage extends StatelessWidget {
  final Plat plat;

  const RecipePage({super.key, required this.plat});

  // --- LOGIQUE DE RANGEMENT DANS LES DOSSIERS (OPTIONNEL) ---
  Future<void> _showFolderPicker(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    const String keyLists = "miaam_favorite_lists";
    final String? data = prefs.getString(keyLists);

    List<Map<String, dynamic>> favoriteLists = [];
    if (data != null) {
      favoriteLists = (jsonDecode(data) as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              const Text("Ranger dans une liste", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (favoriteLists.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Vous n'avez pas encore de listes.\nCréez-en une dans l'onglet Favoris !", textAlign: TextAlign.center),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: favoriteLists.length,
                    itemBuilder: (context, index) {
                      final list = favoriteLists[index];
                      bool dejaPresent = list["plats"].contains(plat.id);

                      return ListTile(
                        leading: Icon(
                          dejaPresent ? Icons.check_circle : Icons.folder_open,
                          color: dejaPresent ? Colors.green : const Color(0xFF6B8E23),
                        ),
                        title: Text(list["name"], style: TextStyle(fontWeight: dejaPresent ? FontWeight.bold : FontWeight.normal)),
                        onTap: () async {
                          if (!dejaPresent) {
                            list["plats"].add(plat.id);
                            await prefs.setString(keyLists, jsonEncode(favoriteLists));
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("📁 Ajouté à : ${list["name"]}"), backgroundColor: const Color(0xFF6B8E23)),
                              );
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- HEADER : IMAGE & ACTIONS ---
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/images_plats/${plat.id}.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/images/placeholder.png', fit: BoxFit.cover),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Consumer<HomePageController>(
                builder: (context, controller, child) {
                  bool liked = controller.isFavorite(plat.id!);
                  
                  return Row(
                    children: [
                      // ⚡ Bouton dossier (visible seulement si favori)
                      if (liked)
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: IconButton(
                            icon: const Icon(Icons.folder_open, color: Color(0xFF6B8E23)),
                            onPressed: () => _showFolderPicker(context),
                          ),
                        ),
                      if (liked) const SizedBox(width: 8),
                      
                      // Bouton cœur
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.7),
                        child: IconButton(
                          icon: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            color: liked ? Colors.red : Colors.black,
                          ),
                          onPressed: () {
                            controller.toggleFavorite(plat);
                            
                            // Feedback avec option de rangement
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  liked 
                                    ? "💔 Retiré des favoris" 
                                    : "❤️ Ajouté aux favoris !"
                                ),
                                duration: const Duration(seconds: 2),
                                backgroundColor: const Color(0xFF6B8E23),
                                action: !liked 
                                  ? SnackBarAction(
                                      label: "📁 Ranger",
                                      textColor: Colors.white,
                                      onPressed: () => _showFolderPicker(context),
                                    )
                                  : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),

          // --- CONTENU DE LA RECETTE ---
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plat.nom, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBadge(Icons.timer_outlined, "${((plat.tempsPreparation ?? 0) + (plat.tempsCuisson ?? 0)).round()} min"),
                      _infoBadge(Icons.group_outlined, "${plat.nbPersonnes ?? '2'} pers."),
                      _infoBadge(Icons.local_fire_department_outlined, "${plat.calories?.round() ?? '--'} kcal"),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Section Ingrédients
                  const Text("Ingrédients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildIngredientsList(),

                  const SizedBox(height: 30),

                  // Section Instructions
                  const Text("Recette", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildSteps(plat.instructions),
                  
                  const SizedBox(height: 30),

                  // ⚡ SECTION : Valeurs Nutritionnelles (DÉROULANTE)
                  if (plat.valeurNutritionnelle != null && plat.valeurNutritionnelle!.isNotEmpty) ...[
                    const Text("Valeurs nutritionnelles", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildNutritionInfo(plat.valeurNutritionnelle!),
                    const SizedBox(height: 30),
                  ],

                  // ⚡ SECTION : Ustensiles
                  if (plat.ustensiles != null && plat.ustensiles!.isNotEmpty) ...[
                    const Text("Ustensiles nécessaires", 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildUstensilesChips(plat.ustensiles!),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE DESIGN ---
  Widget _infoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B8E23)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildIngredientsList() {
    return Column(
      children: plat.ingredients.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.nomIngredient, style: const TextStyle(fontSize: 16)),
              Text("${item.quantite?.toStringAsFixed(1).replaceFirst('.0', '') ?? ''} ${item.unite ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B8E23))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSteps(String? instructions) {
    if (instructions == null) return const Text("Non disponible");
    List<String> steps = instructions.split(RegExp(r'\. |\n')).where((s) => s.trim().isNotEmpty).toList();
    return Column(
      children: List.generate(steps.length, (i) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 12, backgroundColor: const Color(0xFF6B8E23), child: Text("${i+1}", style: const TextStyle(color: Colors.white, fontSize: 12))),
            const SizedBox(width: 10),
            Expanded(child: Text(steps[i], style: const TextStyle(fontSize: 15, height: 1.4))),
          ],
        ),
      )),
    );
  }

  // ⚡ NOUVEAU : Affichage des valeurs nutritionnelles (DÉROULANTE)
  Widget _buildNutritionInfo(String nutritionJson) {
    try {
      // 1. NETTOYAGE MEGA AGRESSIF (CSV a doublé les guillemets)
      String cleanJson = nutritionJson
          .replaceAll('""""', '"')        // """" → " (CSV escape)
          .replaceAll('""', '"')          // "" → "
          .replaceAll('\\"', '"')         // \" → "
          .replaceAll("''", "'")          // '' → '
          .trim();
      
      // 2. Parse avec gestion d'erreur
      Map<String, dynamic> nutrition;
      try {
        nutrition = jsonDecode(cleanJson);
      } catch (e) {
        // Si le JSON est encore cassé, on fait un parsing manuel
        return _buildManualParse(cleanJson);
      }
      
      // 3. Traductions
      const Map<String, String> traductions = {
        'Protein': 'Protéines',
        'Carbohydrates': 'Glucides',
        'Fat': 'Lipides',
        'Saturated Fat': 'Graisses saturées',
        'Unsaturated Fat': 'Graisses insaturées',
        'Fiber': 'Fibres',
        'Sugar': 'Sucres',
        'Sodium': 'Sodium',
        'Cholesterol': 'Cholestérol',
        'Calories': 'Calories',
      };
      
      // 4. Filtrer les valeurs vides
      List<MapEntry<String, dynamic>> validEntries = nutrition.entries
          .where((e) => e.value.toString().trim().isNotEmpty)
          .toList();
      
      if (validEntries.isEmpty) {
        return const Text("Aucune donnée disponible", 
          style: TextStyle(color: Colors.grey));
      }
      
      // 5. ExpansionTile déroulante
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6B8E23).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          title: const Text(
            "Voir les détails",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B8E23),
              fontSize: 16,
            ),
          ),
          leading: const Icon(
            Icons.info_outline,
            color: Color(0xFF6B8E23),
          ),
          trailing: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF6B8E23),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          children: validEntries.map((entry) {
            String nom = traductions[entry.key] ?? entry.key;
            String valeur = entry.value.toString().trim();
            
            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              title: Text(
                nom,
                style: const TextStyle(fontSize: 15),
              ),
              trailing: Text(
                valeur,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8E23),
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
        ),
      );
      
    } catch (e) {
      // Fallback : parsing manuel
      return _buildManualParse(nutritionJson);
    }
  }

  // ⚡ PARSING MANUEL si le JSON est trop cassé
  Widget _buildManualParse(String rawData) {
    try {
      // Extraire les paires clé-valeur manuellement avec regex
      final RegExp pattern = RegExp(r'"([^"]+)":\s*"([^"]*)"');
      final matches = pattern.allMatches(rawData);
      
      if (matches.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Format non reconnu",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }

      const Map<String, String> traductions = {
        'Protein': 'Protéines',
        'Carbohydrates': 'Glucides',
        'Fat': 'Lipides',
        'Saturated Fat': 'Graisses saturées',
        'Unsaturated Fat': 'Graisses insaturées',
        'Fiber': 'Fibres',
        'Sugar': 'Sucres',
        'Sodium': 'Sodium',
        'Cholesterol': 'Cholestérol',
        'Calories': 'Calories',
      };

      List<Widget> items = [];
      for (var match in matches) {
        String key = match.group(1) ?? '';
        String value = match.group(2) ?? '';
        
        if (value.trim().isEmpty) continue;
        
        String nom = traductions[key] ?? key;
        
        items.add(
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(nom, style: const TextStyle(fontSize: 15)),
            trailing: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B8E23),
                fontSize: 15,
              ),
            ),
          ),
        );
      }

      if (items.isEmpty) {
        return const Text("Aucune donnée valide",
          style: TextStyle(color: Colors.grey));
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6B8E23).withOpacity(0.3)),
        ),
        child: ExpansionTile(
          title: const Text(
            "Voir les détails",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B8E23),
              fontSize: 16,
            ),
          ),
          leading: const Icon(Icons.info_outline, color: Color(0xFF6B8E23)),
          trailing: const Icon(Icons.arrow_drop_down, color: Color(0xFF6B8E23)),
          children: items,
        ),
      );
      
    } catch (e) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Erreur d'affichage : ${e.toString()}",
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }
  }

  // ⚡ Affichage des ustensiles
  Widget _buildUstensilesChips(String ustensilesStr) {
    try {
      // Les ustensiles sont stockés comme : ['plat à four', 'casserole', 'four', 'pot']
      // On remplace les quotes simples par doubles pour le JSON
      List<dynamic> ustensiles = jsonDecode(ustensilesStr.replaceAll("'", '"'));
      
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ustensiles.map((u) {
          return Chip(
            label: Text(u.toString()),
            backgroundColor: const Color(0xFF6B8E23).withOpacity(0.15),
            avatar: const Icon(Icons.kitchen, size: 18, color: Color(0xFF6B8E23)),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B8E23),
            ),
          );
        }).toList(),
      );
    } catch (e) {
      // Fallback : afficher le texte brut
      return Text(ustensilesStr, style: const TextStyle(fontSize: 14));
    }
  }
}