import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final String baseUrl =  "http://localhost:3000"; 
  User? get currentUser => _firebaseAuth.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data; // Si l'inscription est réussie, retourne les données.
    } else if (response.statusCode == 400) {
      // Si l'email est déjà utilisé, retourne un message d'erreur spécifique
      throw Exception('L\'email est déjà utilisé. Veuillez en choisir un autre.');
    } else {
      // Autres erreurs génériques
      throw Exception('Échec de l\'inscription. Veuillez réessayer.');
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la connexion');
    }
  }

  Future<void> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la réinitialisation');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser(String idToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la récupération');
    }
  }

  Future<void> signOut() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/logout'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la déconnexion');
    }
  }
}
