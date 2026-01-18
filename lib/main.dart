import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/home_controller.dart';
import 'controllers/search_page_controller.dart';
import 'views/home_page.dart';
import 'views/search_page.dart';
import 'views/favorites_page.dart';
import 'views/splash_screen.dart';
import 'views/tutorial_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomePageController()),
      ChangeNotifierProvider(create: (_) => SearchPageController()),
    ],
    child: const MiaamApp(),
  ));
}

class MiaamApp extends StatelessWidget {
  const MiaamApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6B8E23),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B8E23)),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/tutorial': (context) => const TutorialPage(),
        '/main': (context) => const MainNavigator(),
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
  int cur = 0;
  
  final List<Widget> _pages = const [
    HomePage(), 
    SearchPage(), 
    FavoritesPage()
  ];

  void _showLogsDialog(BuildContext context) {
    // On récupère le contrôleur pour afficher les vraies stats
    final controller = context.read<HomePageController>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.speed, color: Colors.blueGrey),
            SizedBox(width: 10),
            Text("Monitoring Algo"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Métriques de performance en temps réel :", 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildStatRow("Dernière exécution", "${controller.lastExecutionTime} ms", true),
            const Divider(),
            _buildStatRow("Moyenne", "${controller.avgTime.toStringAsFixed(1)} ms", false),
            _buildStatRow("Min", "${controller.minTime} ms", false),
            _buildStatRow("Max", "${controller.maxTime} ms", false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Fermer", style: TextStyle(color: Colors.blueGrey)),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool isMain) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isMain ? const Color(0xFF6B8E23) : Colors.black87,
              fontSize: isMain ? 18 : 14
            )
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le contrôleur juste pour savoir si on affiche le bouton
    // (Optionnel : tu peux enlever le context.watch et le if si tu le veux TOUT le temps)
    final homeController = context.watch<HomePageController>();

    return Scaffold(
      body: IndexedStack(index: cur, children: _pages),
      
      // --- BOUTON DE LOG FLOTTANT (FIXE POUR TOUTE L'APP) ---
      floatingActionButton: homeController.isRecommendationMode 
        ? FloatingActionButton(
            onPressed: () => _showLogsDialog(context),
            backgroundColor: Colors.blueGrey, // Couleur grise demandée
            mini: true, // Petit bouton discret
            child: const Icon(Icons.bar_chart, color: Colors.white),
          )
        : null, // Masqué en mode "Découverte" (ou retire le check pour l'avoir toujours)
        
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: cur, 
          selectedItemColor: const Color(0xFF6B8E23),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          onTap: (i) => setState(() => cur = i), 
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Accueil"),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: "Recherche"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: "Favoris"),
          ]
        ),
      ),
    );
  }
}