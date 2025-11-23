import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> recettesDuJour = [
    {
      'image': 'assets/images/choco_cake.jpg',
      'title': 'Cake au chocolat et amandes en poudre',
      'level': 'Moyen',
      'badge': 'Recette du jour',
    },
    {
      'image': 'assets/images/cupcake.jpg',
      'title': 'Cupcake festif',
      'level': 'Facile',
      'badge': 'Recette du jour',
    },
    {
      'image': 'assets/images/plat_vegetarien.jpg',
      'title': 'Plat végétarien du chef',
      'level': 'Moyen',
      'badge': 'Recette du jour',
    },
    // Ajoute plus de recettes si besoin
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F8F4),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 32, height: 32),
                const SizedBox(width: 8),
                Text(
                  "Miaam",
                  style: TextStyle(
                      color: Color(0xFF6B8E23),
                      fontWeight: FontWeight.w700,
                      fontSize: 22),
                ),
                Spacer(),
                Text(
                  TimeOfDay.now().format(context),
                  style: TextStyle(color: Colors.black38),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                )],
              ),
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Mode découverte'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFE5EBE0),
                        foregroundColor: Color(0xFF6B8E23),
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('Mode recommandation'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Color(0xFFE5EBE0),
                        foregroundColor: Color(0xFF6B8E23),
                        shape: StadiumBorder(),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: recettesDuJour.length,
                    itemBuilder: (context, index) {
                      final r = recettesDuJour[index];
                      return recipeCard(
                        image: r['image']!,
                        title: r['title']!,
                        level: r['level']!,
                        badge: r['badge'],
                      );
                    },
                  ),
                ),
                Positioned(
                  left: -5,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left, size: 39, color: Color(0xFF6B8E23)),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 500), curve: Curves.ease);
                    },
                  ),
                ),
                Positioned(
                  right: -5,
                  child: IconButton(
                    icon: Icon(Icons.chevron_right, size: 39, color: Color(0xFF6B8E23)),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500), curve: Curves.ease);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Les top recettes",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: EdgeInsets.symmetric(horizontal: 22),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.90,
              children: [
                gridRecipeCard(
                  image: 'assets/images/cupcake.jpg',
                  title: 'Tarte aux légumes',
                  level: 'Faible',
                ),
                gridRecipeCard(
                  image: 'assets/images/cupcake.jpg',
                  title: 'Curry végétarien',
                  level: 'Faible',
                ),
                // Ajoute plus de cases si tu veux
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Color(0xFF6B8E23),
          unselectedItemColor: Colors.black38,
          backgroundColor: Colors.white,
          onTap: (index) => setState(() => currentIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'Rechercher'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border), label: 'Favoris'),
          ],
        ),
      ),
    );
  }

  Widget recipeCard({required String image, required String title, required String level, String? badge}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFF6B8E23), width: 3),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6B8E23).withOpacity(0.15),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black12,
            blurRadius: 7,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (badge != null)
            Positioned(
              left: 20,
              top: 15,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
            ),
          Positioned(
            left: 20,
            bottom: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 2)]
                    )),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 17, color: Colors.orange.shade400),
                    Text(' $level',
                        style: TextStyle(color: Colors.orange.shade400, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget gridRecipeCard({required String image, required String title, required String level}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF6B8E23), width: 2),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.65), BlendMode.dstATop),
        ),
        boxShadow: [BoxShadow(color: Color(0xFF6B8E23).withOpacity(0.10), blurRadius: 10)],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            bottom: 17,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.water_drop,
                        size: 16, color: Color(0xFF6B8E23)),
                    Text(' $level',
                        style: TextStyle(
                            color: Color(0xFF6B8E23), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
