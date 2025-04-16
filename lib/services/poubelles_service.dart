import 'package:cloud_firestore/cloud_firestore.dart';


class PoubellesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // Récupérer toutes les poubelles
  Future<List<Map<String, dynamic>>> getPoubelles() async {
    try {
      final snapshot = await _firestore.collection('poubelles').get();


      List<Map<String, dynamic>> poubelles = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'latitude': doc['latitude'],
          'longitude': doc['longitude'],
          'adresse': doc['adresse'],
        };
      }).toList();


      return poubelles;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des poubelles : $e');
    }
  }


  // Ajouter une nouvelle poubelle
  Future<void> addPoubelle(
     double latitude,
     double longitude,
     String adresse,
     String site
  ) async {
    try {
      await _firestore.collection('poubelles').add({
        'latitude': latitude,
        'longitude': longitude,
        'adresse': adresse,
        'site':site,
        'pleine':false
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la poubelle : $e');
    }
  }


  // Modifier une poubelle existante
  Future<void> updatePoubelle({
    required String id,
    required double latitude,
    required double longitude,
    required String adresse,
  }) async {
    try {
      await _firestore.collection('poubelles').doc(id).update({
        'latitude': latitude,
        'longitude': longitude,
        'adresse': adresse,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la poubelle : $e');
    }
  }


  // Supprimer une poubelle
  Future<void> deletePoubelle(String id) async {
    try {
      await _firestore.collection('poubelles').doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la poubelle : $e');
    }
  }
}
