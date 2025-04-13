import 'package:cloud_firestore/cloud_firestore.dart';

class SitesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour récupérer les sites
  Future<List<Map<String, dynamic>>> getSites() async {
    try {
      // Récupérer la collection 'sites' depuis Firestore
      final snapshot = await _firestore.collection('sites').get();

      // Mapper les documents Firestore en une liste de maps
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
  Future<void> addSite(String codeP, String nbPoubelles, String nom) async {
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
  Future<void> updateSite(String id, String codeP, String nbPoubelles, String nom) async {
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
}
