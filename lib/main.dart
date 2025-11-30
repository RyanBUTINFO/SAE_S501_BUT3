import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// --- IMPORTS VUES ---
import 'Views/home_page.dart';
import 'Views/search_page.dart';
import 'Views/favorites_page.dart';
import 'Views/infos_plat.dart';

// --- IMPORTS DATA & CONTROLLERS ---
import 'database/database_helper.dart';
import 'repositories/plat_repository.dart';
import 'controllers/home_page_controller.dart';
import 'controllers/search_page_controller.dart'; // <--- NOUVEL IMPORT

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
    try {
      final tables = await dbHelper.sqfliteDb!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table';",
      );
      print("Tables SQLite trouvées : ${tables.map((t) => t['name']).toList()}");
    } catch (e) {
      print("Erreur lors de la vérification des tables : $e");
    }
  } else {
    print("Base Web initialisée (Sembast)");
  }

  // -------------------------------
  // Test récupération 10 plats aléatoires (Debug console)
  // -------------------------------
  final platRepo = PlatRepository();
  try {
    final randomPlats = await platRepo.getRandomPlats(limit: 10);
    print("=== DEBUG : 10 plats aléatoires chargés au démarrage ===");
    for (var p in randomPlats) {
      print(
          "${p.title} | ${p.level} | ${p.origine} | ${p.image} | ${p.context?.substring(0, p.context!.length > 50 ? 50 : p.context!.length)}...");
    }
  } catch (e) {
    print("Erreur lors du test de récupération des plats : $e");
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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF6B8E23),
          secondary: const Color(0xFFE5EBE0),
        ),
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

  // Liste des pages avec leurs contrôleurs respectifs injectés via Provider
  final List<Widget> pages = [
    // 1. Page Accueil avec son contrôleur
    ChangeNotifierProvider(
      create: (_) => HomePageController(),
      child: const HomePage(),
    ),
    
    // 2. Page Recherche avec son contrôleur (AJOUTÉ ICI)
    ChangeNotifierProvider(
      create: (_) => SearchPageController(),
      child: const SearchPage(),
    ),
    
    // 3. Page Favoris (Pas de contrôleur pour l'instant)
    const FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack = garde l'état des pages (scroll, champs, etc.) quand on change d'onglet
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
          type: BottomNavigationBarType.fixed, // Évite l'animation "shifting" si > 3 items
          backgroundColor: Colors.white,
          elevation: 0, // On gère l'ombre avec le Container au-dessus

          // Couleurs des icônes sélectionnées / non sélectionnées
          selectedItemColor: const Color(0xFF6B8E23),
          unselectedItemColor: Colors.black38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

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
