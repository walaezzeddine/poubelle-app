import 'package:http/http.dart' as http;
import 'dart:convert';


class PoubellesService {
  final String baseUrl = "http://localhost:3000"; // Change si backend est en ligne


  // 📦 Récupérer toutes les poubelles
  Future<List<Map<String, dynamic>>> getPoubelles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/poubelles'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des poubelles : $e');
    }
  }


  // ➕ Ajouter une poubelle
  Future<void> addPoubelle(
      double latitude, double longitude, String adresse, String site) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/poubelles'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
          'adresse': adresse,
          'site': site,
        }),
      );


      if (response.statusCode != 201) {
        throw Exception('Erreur ajout : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la poubelle : $e');
    }
  }


  // 🛠️ Mettre à jour une poubelle
 Future<void> updatePoubelle({
  required String id,
  required double latitude,
  required double longitude,
  required String adresse,
  String? site,
}) async {
  final body = {
    'latitude': latitude,
    'longitude': longitude,
    'adresse': adresse,
  };


  if (site != null) {
    body['site'] = site;
  }


  final response = await http.put(
    Uri.parse('$baseUrl/poubelles/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(body),
  );


  if (response.statusCode != 200) {
    throw Exception('Erreur mise à jour : ${response.body}');
  }
}




  // ❌ Supprimer une poubelle
  Future<void> deletePoubelle(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/poubelles/$id'));


      if (response.statusCode != 200) {
        throw Exception('Erreur suppression : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la poubelle : $e');
    }
  }


  // 🔄 Mettre à jour uniquement le statut "pleine"
  Future<void> updatePleineStatus(String id, bool pleine) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/poubelles/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'pleine': pleine}),
      );


      if (response.statusCode != 200) {
        throw Exception('Erreur statut pleine : ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut pleine : $e');
    }
  }
}



