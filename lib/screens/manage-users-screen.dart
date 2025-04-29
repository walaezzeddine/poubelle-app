import 'package:flutter/material.dart';
import '../../services/users_service.dart';
import '../../screens/admin-menu-drawer.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _users = [];
  List<String> _roles = [];
  String _searchEmail = '';
  String _searchRole = '';
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getUsers();
      setState(() {
        _users = users;
        _roles = _getDistinctRoles(users);
      });
    } catch (e) {
      print('Erreur de chargement des utilisateurs : $e');
    }
  }

  List<String> _getDistinctRoles(List<Map<String, dynamic>> users) {
    Set<String> rolesSet = {};
    for (var user in users) {
      rolesSet.add(user['role']);
    }
    return rolesSet.toList();
  }

  List<Map<String, dynamic>> _filterUsers() {
    return _users.where((user) {
      final emailMatch = user['email'].toLowerCase().contains(_searchEmail.toLowerCase());
      final roleMatch = user['role'].toLowerCase().contains(_searchRole.toLowerCase());
      return emailMatch && roleMatch;
    }).toList();
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final emailController = TextEditingController(text: user?['email']);
    _selectedRole = user?['role'];

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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final role = _selectedRole;

                if (email.isEmpty || role == null) return;
                if (!_isValidEmail(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email invalide.')));
                  return;
                }

                try {
                  if (user == null) {
                    await _userService.addUser(email, role);
                  } else {
                    await _userService.updateUser(user['id'], email, role);
                  }
                  Navigator.pop(context);
                  setState(() {
                    _loadUsers();
                  });
                } catch (e) {
                  print('Erreur : $e');
                }
              },
              child: Text(user == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _userService.deleteUser(userId);
        setState(() {
          _loadUsers();
        });
      } catch (e) {
        print('Erreur lors de la suppression de l\'utilisateur : $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les utilisateurs'),
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
          )]
        ),
      drawer: const AdminMenuDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Liste des utilisateurs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 9, 106, 9))),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Recherche par email', prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 206, 206, 206))),
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
                    decoration: const InputDecoration(labelText: 'Recherche par rôle', prefixIcon: Icon(Icons.person, color: Colors.blue)),
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
                            icon: const Icon(Icons.edit, color: const Color.fromARGB(255, 2, 58, 122)),
                            onPressed: () => _showUserDialog(user: user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
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
              icon: const Icon(Icons.add, color: Color.fromARGB(255, 48, 48, 48)),
              label: const Text('Ajouter un utilisateur'),
            ),
          ],
        ),
      ),
    );
  }
}
