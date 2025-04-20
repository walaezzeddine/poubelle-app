import 'dart:convert';
import 'package:http/http.dart' as http;

class SitesService {
  final String baseUrl = "http://localhost:3000"; // Remplace par ton URL/port backend

  // Récupérer les sites
  Future<List<Map<String, dynamic>>> getSites() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/site/sites'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la récupération des sites : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sites : $e');
    }
  }

Future<void> addSite(int codeP, int nbPoubelles, String nom) async {
  try {

    final response = await http.post(
      Uri.parse('$baseUrl/api/site/sites'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'codeP': codeP,
        'nbPoubelles': nbPoubelles,
        'nom': nom,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur HTTP ${response.statusCode} : ${response.body}');
    }

  } catch (e) {
    print('Erreur capturée dans addSite: $e');
    rethrow; // Rejette vers la UI qui peut alors afficher une alerte propre
  }
}

  // Modifier un site
  Future<void> updateSite(String id, int codeP, int nbPoubelles, String nom) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/site/sites/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'codeP': codeP,
          'nbPoubelles': nbPoubelles,
          'nom': nom,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du site : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du site : $e');
    }
  }

  // Supprimer un site
  Future<void> deleteSite(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/site/sites/$id'));
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du site : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du site : $e');
    }
  }

  // Recherche partielle
  Future<List<Map<String, dynamic>>> searchSitePartial({int? codeP, String? nom}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/site/sites/search?codeP=$codeP&nom=$nom');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la recherche : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche partielle : $e');
    }
  }
}
