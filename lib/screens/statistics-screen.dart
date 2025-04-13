import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques globales',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Exemple de graphique ou de données clés
            Expanded(
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Nombre total d\'utilisateurs'),
                      subtitle: const Text('500 utilisateurs'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Sites actifs'),
                      subtitle: const Text('12 sites'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Nombre de poubelles monitorées'),
                      subtitle: const Text('250 unités'),
                    ),
                  ),
                  // Ajoute des graphiques ou des widgets pour afficher des statistiques
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
