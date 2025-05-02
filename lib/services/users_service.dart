import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  final baseUrl = dotenv.env['API_HOST'];

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/user/users'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  Future<List<Map<String, dynamic>>> getUsersAffected() async {
    final response = await http.get(Uri.parse('$baseUrl/api/user/usersAffected'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }
  // Ajouter un utilisateur
  Future<void> addUser(String cin, String role, String nom, String prenom) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cin': cin, 'role': role, 'nom': nom, 'prenom': prenom}),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de l\'ajout de l\'utilisateur');
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String id, String cin, String role, String nom, String prenom) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/user/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cin': cin, 'role': role, 'nom': nom, 'prenom': prenom}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur');
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/user/users/$id'));
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur');
    }
  }

  // Recherche partielle des utilisateurs
  Future<List<Map<String, dynamic>>> searchUsersPartial(String prenom, String role) async {
    final uri = Uri.parse('$baseUrl/api/user/users/search?prenom=$prenom&role=$role');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la recherche d\'utilisateurs');
    }
  }
}
