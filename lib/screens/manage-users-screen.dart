import 'package:flutter/material.dart';
import '../../services/users_service.dart';
import '../../screens/admin-menu-drawer.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _users = [];
  List<String> _roles = []; // Liste des rôles qui sera mise à jour
  String _searchEmail = '';
  String _searchRole = '';
  String? _selectedRole; // Rôle sélectionné

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Charger les utilisateurs au démarrage
  }

  // Fonction pour charger les utilisateurs et extraire les rôles distincts
  Future<void> _loadUsers() async {
    final users = await _userService.getUsers(); // Récupérer tous les utilisateurs
    setState(() {
      _users = users;
      _roles = _getDistinctRoles(users); // Extraire les rôles distincts
    });
  }

  // Extraire les rôles distincts des utilisateurs
  List<String> _getDistinctRoles(List<Map<String, dynamic>> users) {
    Set<String> rolesSet = {};
    for (var user in users) {
      rolesSet.add(user['role']); // Ajouter chaque rôle unique
    }
    return rolesSet.toList(); // Convertir en liste
  }

  // Filtrer les utilisateurs selon les critères de recherche
  List<Map<String, dynamic>> _filterUsers() {
    return _users.where((user) {
      final emailMatch = user['email'].toLowerCase().contains(_searchEmail.toLowerCase());
      final roleMatch = user['role'].toLowerCase().contains(_searchRole.toLowerCase());
      return emailMatch && roleMatch;
    }).toList();
  }

  // Afficher le dialogue pour ajouter/éditer un utilisateur
  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final emailController = TextEditingController(text: user?['email']);
    _selectedRole = user?['role']; // Pré-sélectionner le rôle si un utilisateur existe

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Ajouter un utilisateur' : 'Modifier utilisateur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (newRole) {
                  setState(() {
                    _selectedRole = newRole;
                  });
                },
                decoration: const InputDecoration(labelText: 'Rôle'),
                hint: const Text('Sélectionner un rôle'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final role = _selectedRole;

                if (email.isEmpty || role == null) return;

                if (user == null) {
                  // Ajouter
                  await _userService.addUser(email, role);
                } else {
                  // Modifier
                  await _userService.updateUser(user['id'], email, role);
                }

                Navigator.pop(context);
                setState(() {
                  _loadUsers(); // Recharger la liste après modification
                });
              },
              child: Text(user == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  // Confirmer la suppression d'un utilisateur
  Future<void> _confirmDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.deleteUser(userId);
      setState(() {
        _loadUsers(); // Recharger la liste après suppression
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
      ),
      drawer: const AdminMenuDrawer(), // ← menu réutilisé
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Liste des utilisateurs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Zone de recherche
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchEmail = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Recherche par rôle',
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchRole = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filterUsers().length,
                itemBuilder: (context, index) {
                  final user = _filterUsers()[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(user['email']),
                      subtitle: Text('Rôle : ${user['role']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showUserDialog(user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(user['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showUserDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un utilisateur'),
            ),
          ],
        ),
      ),
    );
  }
}
