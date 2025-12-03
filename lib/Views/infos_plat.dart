import 'package:flutter/material.dart';
import '../models/plat.dart';

// --- Définitions des Couleurs et Données Statiques ---

const Color _kAppPrimaryColor = Color(0xFF6B8E23); 
const Color _kAccentColor = Color(0xFFEA4C46); 
const Color _kBackgroundColor = Color(0xFFFAF6F0); 


// Données statiques pour le test (à remplacer plus tard)
final List<Map<String, dynamic>> _ingredients = const [
  {'name': '100 g Pâtes (Penne)', 'icon': Icons.ramen_dining},
  {'name': '1 Poulet (escalope)', 'icon': Icons.kebab_dining},
  {'name': '100 g Champignons bruns', 'icon': Icons.pest_control_rodent},
  {'name': '2 poignées Épinards', 'icon': Icons.eco},
  {'name': '1 Kiri', 'icon': Icons.inventory},
  {'name': '1 càs Crème fraîche', 'icon': Icons.local_cafe},
  {'name': '1 pinc. Herbes de Provence', 'icon': Icons.grass},
];

final List<String> _steps = const [
  "Dans une casserole d'eau bouillante salée, faites cuire les pâtes...",
  "Pendant ce temps, lavez puis coupez les champignons en quartiers.",
  "Coupez le poulet en morceaux.",
  "Faites chauffer un filet d'huile d'olive dans une poêle, sur feu moyen...",
  "Ajoutez les champignons et les épinards puis poursuivez la cuisson 3 à 4 minutes...",
  "Ajoutez la crème fraîche, le Kiri et un filet d'eau de cuisson réservée, si besoin...",
  "Ajoutez ensuite les pâtes égouttées et les herbes de Provence. Mélangez à nouveau.",
  "Servez les pâtes crémeuses au poulet, champignons & épinards...",
];

final List<Map<String, String>> _nutritionalValues = const [
  {'name': 'calories', 'value': '436 kcal'},
  {'name': 'Cholesterol', 'value': '128 mg'},
  {'name': 'Protéines', 'value': '46 g'},
  {'name': 'Fibres', 'value': '1 g'},
  {'name': 'Sodium', 'value': '735 mg'},
];

final List<String> _utensils = const [
  "Casserole (pour les pâtes)",
  "Poêle anti-adhésive",
  "Planche à découper",
  "Couteau de cuisine",
  "Cuillère en bois ou spatule",
  "Égouttoir à pâtes",
];


// --- Classe Principale ---


class RecipePage extends StatelessWidget {
  final Plat plat; 

  const RecipePage({super.key, required this.plat}); 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildSliverAppBar(context), 

          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildIntroSection(context), 
                const SizedBox(height: 20),

                _buildInfoSection(context),
                const SizedBox(height: 20),
                
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Ingrédients',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildIngredientsSection(),
                const SizedBox(height: 20),

                // DEPLACEMENT DU CONTEXTE ICI
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      plat.context ?? 'Recette', // Utilise plat.context comme titre de la section recette
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildStepsSection(),
                const SizedBox(height: 20),

                _buildExpandableSection(
                  context, 
                  'Valeurs nutritionnelles', 
                  'Voir les informations nutritionnelles', 
                  null, 
                  _buildNutritionalDetails()
                ),
                const Divider(height: 0),
                
                _buildExpandableSection(
                  context, 
                  'Ustensiles', 
                  'Équipement nécessaire pour la recette', 
                  const Icon(Icons.kitchen, color: Colors.black), 
                  _buildUtensilsDetails()
                ),
                const Divider(height: 0),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNutritionalDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: _nutritionalValues.map((nutrient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nutrient['name']!, 
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                Text(
                  nutrient['value']!, 
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildUtensilsDetails() {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 8.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _utensils.map((utensil) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '• $utensil',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          );
        }).toList(),
      ),
    );
  }


  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _kAppPrimaryColor.withOpacity(0.9),
      expandedHeight: 400.0,
      pinned: true,
      leading: null, 
      automaticallyImplyLeading: false,
      
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 10.0),
        title: const SizedBox.shrink(),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              plat.imagePath ?? 'assets/images_plats/placeholder.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            ),
            
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                  ),
                  
                  Tooltip(
                    message: 'Ajouter aux favoris',
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28), 
                      onPressed: () {
                        // TODO: Logique pour ajouter aux favoris
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildIntroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // TITRE PRINCIPAL
          Text(
            plat.nom ?? plat.title ?? 'Nom non disponible (TEST)', 
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Container(height: 3, width: 80, color: _kAccentColor),
          // CONTEXTE RETIRE ICI
          const SizedBox(height: 12),
          // Suppression du texte plat.context qui a été déplacé
          /*
          Text(
            plat.context ?? 'Les enfants m\'adorent... qui suis-je ?',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          */
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _DataPill(
                value: 'A',
                label: 'Eco-Score', 
                color: Color(0xFFC8E6C9),
              ),
              
              _DataPill(
                value: plat.empreinteCarbone != null ? '${plat.empreinteCarbone!.toStringAsFixed(1)} kg CO2eq' : 'N/A', 
                label: 'Empreinte Carbone', 
                color: const Color(0xFFF0F4C3),
              ),
              
              _DataPill(
                value: plat.origine ?? 'Inconnu', 
                label: 'Origine', 
                color: const Color(0xFFE1BEE7),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          const Divider(),
        ],
      ),
    );
  }


  Widget _buildInfoSection(BuildContext context) {
    String formatTime(double? time) {
      if (time == null) return 'N/A';
      return '${time.round()} min';
    }
  
    return Container(
      color: _kAppPrimaryColor.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TimePill(
            icon: Icons.restaurant, 
            time: formatTime(plat.tempsPreparation), 
            label: 'Préparation'
          ),
          _TimePill(
            icon: Icons.timer, 
            time: formatTime(plat.tempsCuisson), 
            label: 'Cuisson'
          ),
          _TimePill(
            icon: Icons.local_fire_department, 
            time: plat.calories ?? 'N/A', 
            label: 'Par portion'
          ),
        ],
      ),
    );
  }


  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Pour', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_alt, size: 18),
                    const SizedBox(width: 5),
                    Text('${plat.nbPersonnes ?? 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              return _IngredientItem(
                name: _ingredients[index]['name'],
                icon: _ingredients[index]['icon'],
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _steps.length,
        itemBuilder: (context, index) {
          final iconData = index < _ingredients.length ? _ingredients[index]['icon'] : null;

          return _RecipeStep(
            stepNumber: index + 1,
            text: _steps[index],
            icon: iconData,
          );
        },
      ),
    );
  }


  Widget _buildExpandableSection(BuildContext context, String title, String subtitle, Widget? trailingWidget, Widget content) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingWidget != null) trailingWidget,
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
      children: [
        content,
      ],
    );
  }
}


// --- Widgets de support ---


class _TimePill extends StatelessWidget {
  final IconData icon;
  final String time;
  final String label;


  const _TimePill({required this.icon, required this.time, required this.label});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.black, size: 28),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}


class _DataPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;


  const _DataPill({required this.value, required this.label, required this.color});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 8, color: Colors.black54),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}


class _IngredientItem extends StatelessWidget {
  final String name;
  final IconData icon;


  const _IngredientItem({required this.name, required this.icon});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 35, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}


class _RecipeStep extends StatelessWidget {
  final int stepNumber;
  final String text;
  final IconData? icon;


  const _RecipeStep({required this.stepNumber, required this.text, this.icon});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text('$stepNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              // La ligne verticale s'arrête si c'est la dernière étape
              if (stepNumber < 8)
                Container(
                  width: 1.5,
                  height: 60,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}