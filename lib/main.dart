import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/tutorial_page.dart';
import 'database/scripts/database_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


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
        primaryColor: const Color(0xFF6B8E23), // Vert kaki
        fontFamily: 'Arial',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/tutorial': (context) => const TutorialPage(),
      },
    );
  }
}
