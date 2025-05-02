import 'dart:convert';
import 'package:http/http.dart' as http;

class SitesService {
  final String baseUrl = "http://localhost:3000"; // Remplace par ton URL/port backend

  // Récupérer les secteurs
  Future<List<Map<String, dynamic>>> getSecteurs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/secteur/secteurs'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Erreur lors de la récupération des secteurs : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des secteurs : $e');
    }
  }

Future<void> addSecteur(int codeP, int nbPoubelles, String nom, String chauffeurID) async {
  try {

    final response = await http.post(
      Uri.parse('$baseUrl/api/secteur/secteurs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'codeP': codeP,
        'nbPoubelles': nbPoubelles,
        'nom': nom,
        'chauffeurID' : chauffeurID,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur HTTP ${response.statusCode} : ${response.body}');
    }

  } catch (e) {
    print('Erreur capturée dans addSecteur: $e');
    rethrow; // Rejette vers la UI qui peut alors afficher une alerte propre
  }
}

  // Modifier un secteur
  Future<void> updateSecteur(String id, int codeP, int nbPoubelles, String nom, String chauffeurID) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/secteur/secteurs/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'codeP': codeP,
          'nbPoubelles': nbPoubelles,
          'nom': nom,
          'chauffeurID' : chauffeurID,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour du secteur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du secteur : $e');
    }
  }

  // Supprimer un secteur
  Future<void> deleteSecteur(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/secteur/secteurs/$id'));
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du secteur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du secteur : $e');
    }
  }

  // Récupérer un utilisateur par chauffeurID
  Future<Map<String, dynamic>> getUserByChauffeurID(String chauffeurID) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/secteur/secteurs/chauffeur/$chauffeurID'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération du chauffeur : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du chauffeur : $e');
    }
  }

  // Recherche partielle
  Future<List<Map<String, dynamic>>> searchSecteurPartial({int? codeP, String? nom}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/secteur/secteurs/search?codeP=$codeP&nom=$nom');
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

  Future<List<Map<String, dynamic>>> getUsers(String role) async {
    final response = await http.get(Uri.parse('$baseUrl/api/secteur/secteurs/users/$role'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

    // Récupérer le secteur affecté à un chauffeur
  Future<List<String>> getSecteurByChauffeurID(String chauffeurID) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/secteur/secteurs/affectation/$chauffeurID'));
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> secteurs = json.decode(response.body);
      // On extrait uniquement les noms des secteurs
      return secteurs.map<String>((secteur) => secteur['nom'].toString()).toList();
    } else if (response.statusCode == 404) {
      throw Exception('Aucun secteur trouvé pour ce chauffeur');
    } else {
      throw Exception('Erreur lors de la récupération du secteur : ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Erreur lors de la récupération du secteur : $e');
  }
}




}


  