import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertesService {
  final String baseUrl = "http://localhost:3000"; // Change si backend est en ligne

  // 📦 Récupérer toutes les alertes
  Future<List<Map<String, dynamic>>> getAllAlertes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alertes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des alertes : $e');
    }
  }

  // ➕ Ajouter une alerte
    Future<void> createAlerte(String designation, String poubelle, String titre, bool traitee) async {
    try {
        final response = await http.post(
        Uri.parse('$baseUrl/alertes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
            'designation': designation,
            'poubelle': poubelle,
            'titre': titre,
            'traitee': traitee,
        }),
        );
        if (response.statusCode != 201) {
        throw Exception('Erreur ajout : ${response.body}');
        }
    } catch (e) {
        throw Exception('Erreur lors de l\'ajout de l\'alerte : $e');
    }
    }

  // 🛠️ Mettre à jour une alerte
  Future<void> updateAlerte({
    required String id,
    required String designation,
    required String poubelle,
    required String titre,
    required bool traitee,
  }) async {
    final body = {
      'designation': designation,
      'poubelle': poubelle,
      'titre': titre,
      'traitee': traitee,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/alertes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur mise à jour : ${response.body}');
    }
  }

  // ❌ Supprimer une alerte
  Future<void> deleteAlerte(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/alertes/$id'));

      if (response.statusCode != 200) {
        throw Exception('Erreur suppression : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'alerte : $e');
    }
  }

  // 🚀 Générer automatiquement les alertes poubelles pleines
  Future<void> generateAlertesForPoubelles() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alertes/generate'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur génération : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la génération des alertes : $e');
    }
  }
}
