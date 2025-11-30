import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Déclarer le Timer pour pouvoir l'annuler
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    
    // Initialisation du Timer
    _timer = Timer(const Duration(seconds: 3), _handleNavigation);
  }

  // Nouvelle fonction pour gérer la navigation
  void _handleNavigation() {
    // CRITICAL FIX: Vérifier si le widget est toujours dans l'arbre
    if (mounted) {
      // Si la base de données était la cause du blocage initial, 
      // c'est ici qu'il faudrait initialiser la BDD avec un FutureBuilder
      // pour afficher l'écran d'accueil après les 3s + le temps de chargement.
      
      Navigator.pushReplacementNamed(context, '/tutorial');
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Annuler le timer lorsque le widget est retiré
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si l'écran clignote encore, essayez de commenter l'Image.asset
    // pour vérifier si le problème ne vient pas du chargement de l'asset.
    return Scaffold(
      backgroundColor: const Color(0xFF6B8E23), // Vert kaki
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text(
              'Réduire le gaspillage, un repas à la fois',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}