import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool? get mounted => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            // Titre centré et vert
            const Center(
              child: Text(
                'Poubelle',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Bienvenue',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            // Champ Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: UnderlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Champ Mot de passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: UnderlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            // Mot de passe oublié
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/reset-password'),
                child: const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const Divider(height: 40),
            // Bouton de connexion
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CONNEXION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Lien vers inscription
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text.rich(
                  TextSpan(
                    text: "Vous n'avez pas de compte ? ",
                    children: [
                      TextSpan(
                        text: 'S\'inscrire',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _login(BuildContext context) async {
  try {
    final auth = Provider.of<AuthService>(context, listen: false);
    final result = await auth.signInWithRole(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    final role = result['role'] as String;
    
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'chauffeur':
        Navigator.pushReplacementNamed(context, '/collector');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/user');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Erreur: ${e.toString()}"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
}
