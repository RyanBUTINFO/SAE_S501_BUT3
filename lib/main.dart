import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// --- IMPORTS VIEWS ---
import 'Views/home_page.dart';
import 'Views/search_page.dart';
import 'Views/favorites_page.dart';
import 'Views/infos_plat.dart';
import 'Views/splash_screen.dart';
import 'Views/tutorial_page.dart';
// RecommendationPage is removed as it is merged into HomePage
import 'Views/preferences_alimentaires_page.dart'; 

// --- IMPORTS DATA & CONTROLLERS ---
import 'database/database_helper.dart';
import 'controllers/home_page_controller.dart';
import 'controllers/search_page_controller.dart';
// RecommendationController is removed as its logic is merged into HomePageController

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  if (!kIsWeb) {
    try {
      final tables = await dbHelper.sqfliteDb!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table';",
      );
      print("✅ Tables SQLite trouvées : ${tables.map((t) => t['name']).toList()}");
    } catch (e) {
      print("❌ Erreur lors de la vérification des tables : $e");
    }
  } else {
    print("🌐 Base Web initialisée (Sembast)");
  }

  runApp(const MiaamApp());
}

class MiaamApp extends StatelessWidget {
  const MiaamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomePageController()),
        ChangeNotifierProvider(create: (_) => SearchPageController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Miaam',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF6F8F4),
          primaryColor: const Color(0xFF6B8E23),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF6B8E23),
            secondary: const Color(0xFFE5EBE0),
          ),
        ),
        
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/tutorial': (context) => const TutorialPage(),
          '/main': (context) => const MainNavigator(),
          //'/infos_plat': (context) => const RecipePage(),
          '/preferences': (context) => const PreferencesAlimentairesPage(), 
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF6B8E23),
          unselectedItemColor: Colors.black38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (i) => setState(() => currentIndex = i),
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