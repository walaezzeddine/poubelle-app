import 'package:flutter/material.dart';
import 'package:poubelle/screens/admin-dashboard-screen.dart';
import 'package:poubelle/screens/collector-dashboard-screen.dart';
import 'package:poubelle/screens/user-dashboard-screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _cinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _selectedRole = 'agent';

  bool _isValidCin(String cin) {
    final cinRegex = RegExp(r'^\d{8}$'); // exactement 8 chiffres
    return cinRegex.hasMatch(cin);
  }

  bool _isValidPassword(String password) {
    // Minimum 6 caractères, au moins une lettre et un chiffre
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> _register() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final cin = _cinController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isValidCin(cin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cin invalide'),backgroundColor: Colors.red,),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe invalide. Il doit contenir au moins 6 caractères, une lettre et un chiffre.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'),backgroundColor: Colors.red,),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      final result = await auth.register(
        cin,
        password,
        _selectedRole,
        nom,
        prenom,
      );

      final registeredRole = result['role'];

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => _getDashboardForRole(registeredRole)),
          (route) => false,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}'),backgroundColor: Colors.red,),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _getDashboardForRole(String role) {
    switch (role) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'chauffeur':
        return const CollectorDashboardScreen();
      case 'agent':
      default:
        return const UserDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Flèche gauche
          onPressed: () async {
            await Provider.of<AuthService>(context, listen: false).signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          },
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cinController,
                decoration: const InputDecoration(
                  labelText: 'Cin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(
                    value: 'agent',
                    child: Text('Agent'),
                  ),
                  DropdownMenuItem(
                    value: 'chauffeur',
                    child: Text('Chauffeur'),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'S\'INSCRIRE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
