import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final String baseUrl = "http://localhost:3000"; 
  User? get currentUser => _firebaseAuth.currentUser;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isLoggedIn() {
    return _isAuthenticated;
  }

  String? _role = ''; // Nullable field

  // Getter for _role
  String? get role => _role;

  // Setter for _role
  set role(String? newRole) {
    _role = newRole;
    notifyListeners();  // Notify listeners when _role changes
  }

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  set isAuthenticated(bool status) {
    _isAuthenticated = status;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  // Other methods like register, login, etc.
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _role = data['role']; // Assuming the role is part of the user data
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la connexion');
    }
  }


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
      final data = jsonDecode(response.body);
      _role = data['role']; // Assuming the role is part of the user data
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la récupération');
    }
  }

  Future<void> signOut() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/logout'),
    );
    _isAuthenticated = false;
    _role = null; // Reset role on logout
    notifyListeners();
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la déconnexion');
    }
  }
}
