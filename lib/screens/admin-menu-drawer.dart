// lib/widgets/admin_menu_drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AdminMenuDrawer extends StatelessWidget {
  const AdminMenuDrawer({super.key});

void _checkAuthAndNavigate(BuildContext context, String routeName) {
  final authService = Provider.of<AuthService>(context, listen: false);
  final isLoggedIn = authService.isLoggedIn();

  if (isLoggedIn) {
    Navigator.pushNamed(context, routeName);
  } else {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'Menu Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Gérer les utilisateurs'),
            onTap: () => _checkAuthAndNavigate(context, '/manage-users'),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Gérer les secteurs'),
            onTap: () => _checkAuthAndNavigate(context, '/manage-sites'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Gérer les poubelles'),
            onTap: () => _checkAuthAndNavigate(context, '/manage-poubelles'),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Statistiques'),
            onTap: () => _checkAuthAndNavigate(context, '/statistics'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () async {
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
    );
  }
}
