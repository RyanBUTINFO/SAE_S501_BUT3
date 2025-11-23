import 'package:flutter/material.dart';

// --- Définitions des Couleurs et Données (Rendus accessibles globalement) ---

// Couleurs dérivées des images fournies
const Color _kPrimaryColor = Color(0xFFF09855); // Jaune/Orange de la bannière
const Color _kAccentColor = Color(0xFFEA4C46); // Rouge des boutons et étoiles
const Color _kBackgroundColor = Color(0xFFFAF6F0); // Couleur de fond très claire
const Color _kNoteColor = Color(0xFFFDECD9); // Fond de la section "Notes perso"

// Liste des ingrédients (pour la GridView)
final List<Map<String, dynamic>> _ingredients = const [
  {'name': '100 g Pâtes (Penne)', 'icon': Icons.ramen_dining},
  {'name': '1 Poulet (escalope)', 'icon': Icons.kebab_dining},
  {'name': '100 g Champignons bruns', 'icon': Icons.pest_control_rodent},
  {'name': '2 poignées Épinards', 'icon': Icons.eco},
  {'name': '1 Kiri', 'icon': Icons.inventory},
  {'name': '1 càs Crème fraîche', 'icon': Icons.local_cafe},
  {'name': '1 pinc. Herbes de Provence', 'icon': Icons.grass},
];

// Liste des étapes de la recette (pour la ListView)
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


// --- Classe Principale ---

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          // L'en-tête de la page
          _buildSliverAppBar(),

          // Contenu principal sous l'en-tête
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildIntroSection(context),
                const SizedBox(height: 20),

                _buildInfoSection(context),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Ingrédients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                _buildIngredientsSection(),
                const SizedBox(height: 20),

                _buildEnsureSection(context),
                const SizedBox(height: 20),

                _buildStepsSection(),
                const SizedBox(height: 20),

                _buildNotesSection(context),
                const SizedBox(height: 20),

                // Sections repliables
                _buildExpandableSection(context, 'Valeurs nutritionnelles', 'Voir les informations nutritionnelles', null),
                const Divider(height: 0),
                _buildExpandableSection(context, 'Prix par portion', '€€€', const Icon(Icons.euro, color: Colors.blue)),
                const Divider(height: 0),
                _buildExpandableSection(context, 'Scores', 'NUTRI-SCORE ABCDE', const Icon(Icons.score, color: Colors.green)),
                const Divider(height: 0),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      // Bouton flottant du bas
      bottomSheet: _buildBottomSheet(context),
    );
  }

  // En-tête de la page (SliverAppBar)
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: _kPrimaryColor, // La couleur de fond derrière l'image si elle ne couvre pas tout
      expandedHeight: 400.0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () {},
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(Icons.favorite_border, color: Colors.black),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 10.0),
        title: const SizedBox.shrink(),
        background: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // L'image de la recette chargée depuis les assets
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images_plats/poulet_pate_cremeuse.jpg',
                      fit: BoxFit.cover, // S'assure que l'image couvre tout l'espace disponible
                    ),
                  ),
                  // Bannière rayée jaune/orange (si vous voulez la superposer)
                  // Si l'image contient déjà la bannière, retirez ceci.
                  // Si la bannière doit être au-dessus, elle irait ici.
                  // Exemple pour la bannière par-dessus l'image:
                  // Positioned(
                  //   top: 0,
                  //   left: 0,
                  //   right: 0,
                  //   height: 100, // Hauteur de la bannière
                  //   child: Container(
                  //     color: _kPrimaryColor.withOpacity(0.5), // Ou une image de bannière
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section d'introduction (Titre, Notes, Facilité, Scores)
  Widget _buildIntroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < 3 ? Icons.star : (index == 3 ? Icons.star_half : Icons.star_border),
                color: _kAccentColor,
              );
            }),
          ),
          const Text('18 notes', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            'Pâtes crémeuses au poulet, champignons & épinards',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 8),
          Container(height: 3, width: 80, color: _kAccentColor),
          const SizedBox(height: 12),
          const Text(
            'Les enfants m\'adorent... qui suis-je ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const _ScorePill(text1: '€€€', text2: 'Prix', icon: null),
              const _ScorePill(text1: 'Très facile', text2: '', icon: Icons.bar_chart),
              // Simuler les scores (Utiliser Image.asset si dispo)
              // Assurez-vous d'avoir ces assets si vous les décommentez
              // Image.asset('assets/nutriscore_placeholder.png', height: 30),
              // Image.asset('assets/eco_score_placeholder.png', height: 30),
              // Placeholders temporaires
              Container(width: 50, height: 30, color: Colors.green.shade200, child: const Center(child: Text('Nutri', style: TextStyle(fontSize: 10)))),
              Container(width: 50, height: 30, color: Colors.yellow.shade200, child: const Center(child: Text('Eco', style: TextStyle(fontSize: 10)))),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share, size: 20),
              const SizedBox(width: 5),
              const Text('Partager', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text('3.3k', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              Icon(Icons.favorite, size: 20, color: _kAccentColor),
            ],
          ),
        ],
      ),
    );
  }

  // Section Préparation/Cuisson/Calories
  Widget _buildInfoSection(BuildContext context) {
    return Container(
      color: _kPrimaryColor.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TimePill(icon: Icons.edit, time: '5 minutes', label: 'Préparation'),
          _TimePill(icon: Icons.timer, time: '12 minutes', label: 'Cuisson'),
          _TimePill(icon: Icons.local_fire_department, time: '751 kcal', label: 'Par portion'),
        ],
      ),
    );
  }

  // Section des ingrédients (GridView)
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
                child: const Row(
                  children: [
                    Icon(Icons.people_alt, size: 18),
                    SizedBox(width: 5),
                    Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Icon(Icons.arrow_drop_down, size: 18),
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

  // Section "Assurez-vous d'avoir..."
  Widget _buildEnsureSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assurez-vous d\'avoir...',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Huile d\'olive (1 càc)', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 5),
              Icon(Icons.info_outline, size: 16, color: Theme.of(context).primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  // Section des étapes de la recette (ListView)
  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recette',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ListView.builder(
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
        ],
      ),
    );
  }

  // Section Notes Perso
  Widget _buildNotesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _kNoteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes perso',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          const Text('Votre grain de sel dans la recette !'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Touchez pour ajouter une note privée', style: TextStyle(color: Colors.grey)),
                Icon(Icons.edit, color: Colors.grey.shade600),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Barre de notation (simulée)
          Row(
            children: List.generate(8, (i) {
              return Expanded(
                child: Container(
                  height: 15,
                  margin: const EdgeInsets.only(right: 4),
                  color: i % 2 == 0 ? Colors.red : Colors.orange,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Section repliable générique
  Widget _buildExpandableSection(BuildContext context, String title, String subtitle, Widget? trailingWidget) {
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
      children: const [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Contenu détaillé de la section...'),
        ),
      ],
    );
  }

  // Bouton fixe en bas de page
  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: const SafeArea( // Utilisation de const car le contenu est maintenant statique
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Le bouton 'Retirer du menu' a été supprimé ici
            
            // Le message de partage est conservé
            Text(
              'Vous avez réalisé cette recette ? Partagez votre œuvre sur Insta',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
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

class _ScorePill extends StatelessWidget {
  final String text1;
  final String text2;
  final IconData? icon;

  const _ScorePill({required this.text1, required this.text2, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) Icon(icon, size: 30, color: const Color(0xFF333333)),
        if (icon == null) Text(text1, style: const TextStyle(fontSize: 24, color: Color(0xFF333333))),
        Text(text2, style: const TextStyle(fontSize: 12)),
      ],
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
                child: icon != null
                    ? Icon(icon, size: 20, color: Colors.grey.shade600)
                    : Text('$stepNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
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
                Text(
                  'Étape $stepNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(text, style: const TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}