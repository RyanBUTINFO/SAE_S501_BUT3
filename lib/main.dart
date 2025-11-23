import 'package:flutter/material.dart';
import 'Views/splash_screen.dart';
import 'Views/tutorial_page.dart';
import 'Models/database/scripts/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'Views/home_page.dart';
// J'ai renommé le fichier de destination en 'infos_plat.dart' et la classe en 'RecipePage'
import 'Views/infos_plat.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  // Vérification uniquement sur mobile/desktop (SQLite)
  if (!kIsWeb) {
    final tables = await dbHelper.sqfliteDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';"
    );
    print("Tables créées : ${tables.map((t) => t['name']).toList()}");
  } else {
    print("Base web prête (Sembast)");
  }
  runApp(const MiaamApp());
}

class MiaamApp extends StatelessWidget {
  const MiaamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miaam',
      theme: ThemeData(
        // Le thème principal de l'application (vert kaki)
        primaryColor: const Color(0xFF6B8E23), 
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/tutorial': (context) => const TutorialPage(),
        // 👈 Votre nouvelle page de recette est ajoutée ici
        '/infos_plat': (context) => const RecipePage(),
      }, 
    );
  }
}