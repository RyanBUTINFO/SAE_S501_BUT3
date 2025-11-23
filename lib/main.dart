import 'package:flutter/material.dart';
import 'Views/splash_screen.dart';
import 'Views/tutorial_page.dart';
import 'Views/home_page.dart';
import 'database/database_helper.dart';
import 'repositories/plat_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la base
  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  // Vérification des tables SQLite uniquement si pas web
  if (!kIsWeb) {
    final tables = await dbHelper.sqfliteDb!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';"
    );
    print("Tables créées : ${tables.map((t) => t['name']).toList()}");
  } else {
    print("Base web prête (Sembast)");
  }

  // ------------------ Tests équipe  backend en console ------------------
  print('-------------------------------------------------');
  print("\n\n\n  Tests effetués par l'équipe de backend :  ");

  final platRepo = PlatRepository();
  final allPlats = await platRepo.getTopPlatsByOrigine('America', limit: 10);

  // 1) Récupérer les 10 premiers plats dont origine contient "America"
  print('--- 1) Test sur 10 premiers plats contenant "America" dans l\'origine ---');
  for (var plat in allPlats) {
    print('${plat.id} - ${plat.nom} (Origine: ${plat.origine})');
  }

  //Suite de tests ...

  print("\n Fin Tests de l'équipe du backend \n");
  print('-------------------------------------------------');

  // Lancement de l'application Flutter
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
        primaryColor: const Color(0xFF6B8E23), // Vert kaki
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/tutorial': (context) => const TutorialPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
