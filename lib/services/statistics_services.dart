import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<int> getUserCount() async {
    try {
        final snapshot = await _firestore
            .collection('users')
            .where('role', isNotEqualTo: 'admin')
            .get();
        return snapshot.docs.length;
    } catch (e) {
        throw 'Erreur lors de la récupération des utilisateurs : ${e.toString()}';
    }
    }

  // Fonction pour récupérer le nombre d'utilisateurs par rôle
    Future<Map<String, int>> getUserCountsByRoles() async {
    try {
        final snapshot = await _firestore
            .collection('users')
            .where('role', isNotEqualTo: 'admin')
            .get();

        Map<String, int> roleCounts = {};
        for (var doc in snapshot.docs) {
        final role = doc['role'] ?? 'inconnu';
        roleCounts[role] = (roleCounts[role] ?? 0) + 1;
        }
        return roleCounts;
    } catch (e) {
        throw 'Erreur lors de la récupération des utilisateurs par rôle : ${e.toString()}';
    }
    }

  // Fonction pour récupérer le nombre total de poubelles
  Future<int> getTotalPoubelles() async {
    try {
      final snapshot = await _firestore.collection('sites').get();
      int totalPoubelles = 0;
      for (var doc in snapshot.docs) {
        int nbPoubelle = doc['nbPoubelles'] != null
            ? (doc['nbPoubelles'] as num).toInt()
            : 0;
        totalPoubelles += nbPoubelle;
      }
      return totalPoubelles;
    } catch (e) {
      throw 'Erreur lors de la récupération du total des poubelles : ${e.toString()}';
    }
  }

  // Fonction pour récupérer le nombre de poubelles pleines et vides
  Future<Map<String, int>> getPoubellesStatus() async {
    try {
      final snapshot = await _firestore.collection('poubelles').get();
      int poubellesPlein = 0;
      int poubellesVide = 0;

      for (var doc in snapshot.docs) {
        bool isPlein =
            doc['pleine'] != null ? doc['pleine'] as bool : false;
        if (isPlein) {
          poubellesPlein++;
        } else {
          poubellesVide++;
        }
      }
      return {'plein': poubellesPlein, 'vide': poubellesVide};
    } catch (e) {
      throw 'Erreur lors de la récupération du statut des poubelles : ${e.toString()}';
    }
  }
}
