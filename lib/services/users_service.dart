import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer la liste des utilisateurs
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final users = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'email': doc['email'],
          'role': doc['role'],
        };
      }).toList();

      // Filtrage des administrateurs dans le code
      final filteredUsers = users.where((user) => user['role'] != 'admin').toList();

      return filteredUsers;
    } catch (e) {
      throw 'Erreur lors de la récupération des utilisateurs: ${e.toString()}';
    }
  }

    Future<List<Map<String, dynamic>>> searchUsersPartial({String? email, String? role}) async {
    try {
        Query query = _firestore.collection('users');

        if (email != null && email.isNotEmpty) {
        query = query
            .orderBy('email')
            .startAt([email])
            .endAt(['$email\uf8ff']);
        }

        final snapshot = await query.get();

        // Filtrage local des utilisateurs
        final users = snapshot.docs.map((doc) {
        return {
            'id': doc.id,
            'email': doc['email'],
            'role': doc['role'],
        };
        }).toList();

        // Si un rôle est spécifié, on applique un filtrage pour le rôle
        if (role != null && role.isNotEmpty) {
        // Recherche par rôle
        final filteredByRole = users.where((user) =>
            user['role'].toString().toLowerCase().contains(role.toLowerCase())
        ).toList();

        // Exclure les administrateurs de la recherche, même si le rôle "admin" est recherché
        return filteredByRole.where((user) => user['role'] != 'admin').toList();
        }

        // Si aucun rôle n'est spécifié, retourner tous les utilisateurs en excluant les administrateurs
        return users.where((user) => user['role'] != 'admin').toList();
    } catch (e) {
        throw 'Erreur lors de la recherche partielle : ${e.toString()}';
    }
    }

  // Ajouter un utilisateur
  Future<void> addUser(String email, String role) async {
    try {
      await _firestore.collection('users').add({
        'email': email,
        'role': role,
      });
    } catch (e) {
      throw 'Erreur lors de l\'ajout de l\'utilisateur: ${e.toString()}';
    }
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(String id, String email, String role) async {
    try {
      await _firestore.collection('users').doc(id).update({
        'email': email,
        'role': role,
      });
    } catch (e) {
      throw 'Erreur lors de la mise à jour de l\'utilisateur: ${e.toString()}';
    }
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw 'Erreur lors de la suppression de l\'utilisateur: ${e.toString()}';
    }
  }
}
