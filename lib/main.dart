import 'package:flutter/material.dart';
import 'Views/home_page.dart';
import 'Views/search_page.dart';
import 'Views/favorites_page.dart';
import 'Views/infos_plat.dart';
import 'database/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  // Nécessaire pour utiliser du code async avant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // -------------------------------
  // Initialisation de la base locale
  // -------------------------------
  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  // Vérification debug des tables en SQLite (mobile)
  if (!kIsWeb) {
    final tables = await dbHelper.sqfliteDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';",
    );
    print("Tables SQLite trouvées : ${tables.map((t) => t['name']).toList()}");
  } else {
    print("Base Web initialisée (Sembast)");
  }

  // Lancement de l'application Flutter
  runApp(const MiaamApp());
}

class MiaamApp extends StatelessWidget {
  const MiaamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Thème général de l'application
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F8F4),
        primaryColor: const Color(0xFF6B8E23), // Kaki
      ),

      // Page principale = navigation avec bottom bar
      home: const MainNavigator(),

      // Déclaration des routes globales
      routes: {
        '/infos_plat': (context) => const RecipePage(), // Page infos d’un plat
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  // Index de la page active dans la bottom navigation
  int currentIndex = 0;

  // Liste des pages affichées
  final List<Widget> pages = [
    const HomePage(),
    const SearchPage(),
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack = garde l'état des pages (scroll, champs, etc.)
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // Barre de navigation du bas
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6, // Petite ombre élégante
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: currentIndex,

          // Couleurs des icônes sélectionnées / non sélectionnées
          selectedItemColor: const Color(0xFF6B8E23),
          unselectedItemColor: Colors.black38,

          // Changement d'onglet
          onTap: (i) => setState(() => currentIndex = i),

          // Items de la navigation
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          ],
        ),
      ),
    );
  }
}
