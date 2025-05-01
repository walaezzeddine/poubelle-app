// lib/widgets/user_menu_drawer.dart


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';


class UserMenuDrawer extends StatelessWidget {
  const UserMenuDrawer({super.key});


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
              'Menu Agent',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Gérer les poubelles'),
            onTap: () {
              Navigator.pushNamed(context, '/manage-poubelles');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Gérer les secteurs'),
            onTap: () {
              Navigator.pushNamed(context, '/manage-sites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Statistiques'),
            onTap: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () async {
              await Provider.of<AuthService>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}


