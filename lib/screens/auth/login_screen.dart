import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:poubelle/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatelessWidget {
  final baseUrl = dotenv.env['API_HOST'];
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fonction pour valider le cin
  bool _isValidCin(String cin) {
    final cinRegex = RegExp(r'^\d{8}$'); // exactement 8 chiffres
    return cinRegex.hasMatch(cin);
  }

  // Fonction pour valider le mot de passe
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> _login(BuildContext context) async {
    final cin = _cinController.text.trim();
    final password = _passwordController.text.trim();

    // Validation before sending
    if (!_isValidCin(cin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le CIN doit contenir exactement 8 chiffres."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le mot de passe doit contenir au moins 6 caractères."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print(baseUrl);
      final response = await http.post(
         Uri.parse('$baseUrl/api/auth/login'),
        //Uri.parse('http://192.168.56.1:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cin': cin, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update role in AuthService based on response
        Provider.of<AuthService>(context, listen: false).setAuthenticated(true);
        Provider.of<AuthService>(context, listen: false).role = data['role']; 
        Provider.of<AuthService>(context, listen: false).userId = data['uid']; // Update the role

        // Navigate based on role
        switch (data['role']) {
          case 'admin':
            Navigator.pushReplacementNamed(context, '/statistics');
            break;
          case 'chauffeur':
            Navigator.pushReplacementNamed(context, '/collector');
            break;
          case 'agent':
            Navigator.pushReplacementNamed(context, '/manage-poubelles');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/collector');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Utilisateur inexistant, veuillez vous inscrire !"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'EcoVia',
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _cinController,
              decoration: const InputDecoration(
                labelText: 'Matricule',
                border: UnderlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
