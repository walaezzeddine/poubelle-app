import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StatisticsService {
 final baseUrl = dotenv.env['API_HOST'];

  // ➤ Nombre total d'utilisateurs
  Future<int> getUserCount() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stat/userCount'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['count'];
    } else {
      throw Exception('Erreur lors de la récupération du nombre d\'utilisateurs');
    }
  }

  // ➤ Nombre d'utilisateurs par rôle
  Future<Map<String, int>> getUserCountsByRoles() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stat/userCountsByRoles'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Erreur lors de la récupération des rôles');
    }
  }

  // ➤ Total des poubelles
  Future<int> getTotalPoubelles() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stat/totalPoubelles'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['total'];
    } else {
      throw Exception('Erreur lors de la récupération du nombre total de poubelles');
    }
  }

  // ➤ Statut des poubelles (pleines vs vides)
  Future<Map<String, int>> getPoubellesStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/stat/poubellesStatus'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.map((key, value) => MapEntry(key, value as int));
    } else {
      throw Exception('Erreur lors de la récupération du statut des poubelles');
    }
  }
}
