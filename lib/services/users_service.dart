import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "http://localhost:3000";

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/user/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  // Ajouter un utilisateur
  Future<void> addUser(String email, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'role': role}),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout de l\'utilisateur');
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String id, String email, String role) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/user/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'role': role}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/user/users/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur');
    }
  }

  // Recherche partielle des utilisateurs
  Future<List<Map<String, dynamic>>> searchUsersPartial(String email, String role) async {
    final uri = Uri.parse('$baseUrl/api/user/users/search?email=$email&role=$role');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la recherche d\'utilisateurs');
    }
  }
}
