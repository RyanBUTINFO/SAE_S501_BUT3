import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/tutorial_page.dart';

void main() {
  runApp(const FoodWasteZeroApp());
}

class FoodWasteZeroApp extends StatelessWidget {
  const FoodWasteZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodWasteZero',
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