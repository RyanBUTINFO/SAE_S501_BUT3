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
        // On définit le style global ici pour éviter les surprises
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
  
  // Les pages de ton appli
  final List<Widget> _pages = const [
    HomePage(), 
    SearchPage(), 
    FavoritesPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack permet de garder l'état des pages quand on switch
      body: IndexedStack(index: cur, children: _pages),
      
      // LA SEULE ET UNIQUE BARRE DE NAV
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
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