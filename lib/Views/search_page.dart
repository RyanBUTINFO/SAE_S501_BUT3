import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F4),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 32, height: 32,
                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 32, color: Color(0xFF6B8E23))),
                const SizedBox(width: 8),
                const Text("Miaam", style: TextStyle(color: Color(0xFF6B8E23), fontWeight: FontWeight.w700, fontSize: 22)),
                const Spacer(),
                Text(TimeOfDay.now().format(context), style: const TextStyle(color: Colors.black38)),
              ],
            ),
          ),
        ),
      ),
      body: const Center(child: Text('Recherche')),
    );
  }
}