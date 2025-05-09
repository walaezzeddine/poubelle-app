import 'package:flutter/material.dart';
import '../../services/users_service.dart';
import '../../screens/admin-menu-drawer.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _usersAffected = []; // Ajout de cette variable
  List<String> _roles = [];
  String _searchPrenom = '';
  String _searchRole = '';
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  bool _isValidCin(String cin) {
    final cinRegex = RegExp(r"^\d{8}$"); // 8 chiffres
    return cinRegex.hasMatch(cin);
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getUsers();
      final usersAffected = await _userService.getUsersAffected();
      setState(() {
        _users = users;
        _usersAffected = usersAffected; // Ajout du chargement des utilisateurs affectés
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
      final prenom = user['prenom'] ?? ''; // Valeur par défaut si `prenom` est null
      final role = user['role'] ?? ''; // Valeur par défaut si `role` est null
      final prenomMatch = prenom.toLowerCase().contains(_searchPrenom.toLowerCase());
      final roleMatch = role.toLowerCase().contains(_searchRole.toLowerCase());
      return prenomMatch && roleMatch;
    }).toList();
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final cinController = TextEditingController(text: user?['cin']);
    final nomController = TextEditingController(text: user?['nom']);
    final prenomController = TextEditingController(text: user?['prenom']);
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
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: cinController,
                decoration: const InputDecoration(labelText: 'cin'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(value: role, child: Text(role));
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
                final cin = cinController.text.trim();
                final role = _selectedRole;
                final nom = nomController.text.trim();
                final prenom = prenomController.text.trim();

                if (cin.isEmpty || nom.isEmpty || prenom.isEmpty || role == null) return;
                if (!_isValidCin(cin)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cin invalide.'), backgroundColor: Colors.red));
                  return;
                }

                try {
                  if (user == null) {
                    await _userService.addUser(cin, role, nom, prenom);
                  } else {
                    await _userService.updateUser(user['id'], cin, role, nom, prenom);
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
    // Vérifier si l'utilisateur est affecté avant la suppression

    final isUserAffected = _usersAffected.any((user) => user['chauffeurID'] == userId);

    if (isUserAffected) {
      // Si l'utilisateur est affecté, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cet utilisateur est affecté à un secteur et ne peut pas être supprimé.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Ne pas continuer la suppression
    }

    // Si l'utilisateur n'est pas affecté, demander la confirmation de la suppression
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé avec succès !'), backgroundColor: Colors.green),
        );
        setState(() {
          _loadUsers();  // Recharger la liste des utilisateurs après suppression
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression de l\'utilisateur : $e'), backgroundColor: Colors.red),
        );
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
          ),
        ],
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
                    decoration: const InputDecoration(labelText: 'Recherche par prénom', prefixIcon: Icon(Icons.email, color: Color.fromARGB(255, 206, 206, 206))),
                    onChanged: (value) {
                      setState(() {
                        _searchPrenom = value;
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
                      title: Text('${user['nom']} ${user['prenom']}'),
                      subtitle: Text('CIN : ${user['cin']} | Rôle : ${user['role']}'),
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
                if (result == true) {
                  _loadUsers(); // Recharger la liste après ajout
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un utilisateur'),
            ),
          ],
        ),
      ),
    );
  }
}
