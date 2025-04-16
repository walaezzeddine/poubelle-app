import 'package:cloud_firestore/cloud_firestore.dart';

class SitesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour récupérer les sites
  Future<List<Map<String, dynamic>>> getSites() async {
    try {
      final snapshot = await _firestore.collection('sites').get();
      List<Map<String, dynamic>> sites = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'codeP': doc['codeP'],
          'nbPoubelles': doc['nbPoubelles'],
          'nom': doc['nom'],
        };
      }).toList();
      return sites;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des sites : $e');
    }
  }

  // Fonction pour ajouter un site
  Future<void> addSite(int codeP, int nbPoubelles, String nom) async {
    try {
      await _firestore.collection('sites').add({
        'codeP': codeP,
        'nbPoubelles': nbPoubelles,
        'nom': nom,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du site : $e');
    }
  }

  // Fonction pour modifier un site
  Future<void> updateSite(String id, int codeP, int nbPoubelles, String nom) async {
    try {
      await _firestore.collection('sites').doc(id).update({
        'codeP': codeP,
        'nbPoubelles': nbPoubelles,
        'nom': nom,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du site : $e');
    }
  }

  // Fonction pour supprimer un site
  Future<void> deleteSite(String id) async {
    try {
      await _firestore.collection('sites').doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du site : $e');
    }
  }

  // Fonction de recherche partielle
Future<List<Map<String, dynamic>>> searchSitePartial({int? codeP, String? nom}) async {
  try {
    // Récupérer tous les sites (attention si la collection est très grande)
    final snapshot = await FirebaseFirestore.instance.collection('sites').get();

    // Transformation en liste
    List<Map<String, dynamic>> sites = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'codeP': doc['codeP'],
        'nom': doc['nom'],
      };
    }).toList();

    // Filtrage local par codeP si fourni
    if (codeP != null) {
      sites = sites.where((site) => site['codeP'] == codeP).toList();
    }

    // Filtrage local par nom si fourni
    if (nom != null && nom.isNotEmpty) {
      sites = sites.where((site) => site['nom'].toLowerCase().contains(nom.toLowerCase())).toList();
    }

    // Exclure les noms admin
    return sites.where((site) => site['nom'] != 'admin').toList();
  } catch (e) {
    throw 'Erreur lors de la recherche partielle : ${e.toString()}';
  }
}


}
