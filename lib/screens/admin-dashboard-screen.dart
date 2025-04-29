import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'admin-menu-drawer.dart'; // ← importe ton menu réutilisable
import '../screens/auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false, // Supprime toutes les routes précédentes
            );
            },
          ),
        ],
      ),
      drawer: const AdminMenuDrawer(), // ← utilise le menu ici
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vous êtes connecté en tant qu\'administrateur'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manage-users');
              },
              child: const Text('Gérer les utilisateurs'),
            ),
          ],
        ),
      ),
    );
  }
}
