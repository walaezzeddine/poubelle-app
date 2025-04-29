import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'package:poubelle/screens/user-menu-drawer.dart';
import '../screens/auth/login_screen.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});


  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Agent'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vous êtes connecté en tant qu\'agent de municipalité'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/manage-poubelles');
              },
              child: const Text('Gérer les poubelles'),
            ),
          ],
        ),
      ),
    );
  }
}

