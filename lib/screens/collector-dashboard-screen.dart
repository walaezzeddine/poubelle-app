import 'package:flutter/material.dart';

class CollectorDashboardScreen extends StatelessWidget {
  const CollectorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Collecteur')),
      body: const Center(
        child: Text('Espace collecteur de déchets'),
      ),
    );
  }
}