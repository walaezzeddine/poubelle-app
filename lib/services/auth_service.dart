import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enregistrement amélioré avec retour du rôle
  Future<Map<String, dynamic>> register(String email, String password, String role) async {
    try {
      // 1. Création du compte Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Enregistrement dans Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Retour des infos complètes
      return {
        'user': userCredential.user,
        'role': role,
        'uid': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erreur inattendue: ${e.toString()}';
    }
  }

  // Connexion avec gestion améliorée
  Future<Map<String, dynamic>> signInWithRole(String email, String password) async {
    try {
      // 1. Authentification
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Récupération du rôle avec timeout
      final doc = await _firestore.collection('users')
          .doc(userCredential.user?.uid)
          .get()
          .timeout(const Duration(seconds: 5));

      if (!doc.exists) {
        await _auth.signOut();
        throw 'Profil incomplet. Veuillez vous réinscrire.';
      }

      // 3. Retour des données complètes
      return {
        'user': userCredential.user,
        'role': doc['role'] ?? 'user',
        'uid': userCredential.user?.uid,
      };
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on TimeoutException {
      throw 'Le service met trop de temps à répondre';
    } catch (e) {
      throw 'Erreur de connexion: ${e.toString()}';
    }
  }

  // Réinitialisation avec vérification
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email)
          .timeout(const Duration(seconds: 5));
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on TimeoutException {
      throw 'Timeout lors de l\'envoi de l\'email';
    }
  }

  // Gestion des erreurs améliorée
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Format email invalide';
      case 'weak-password':
        return 'Le mot de passe doit faire au moins 6 caractères';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion';
      default:
        return 'Erreur: ${e.message ?? "Code d'erreur: ${e.code}"}';
    }
  }

  // Déconnexion sécurisée
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erreur déconnexion: $e');
      rethrow;
    }
  }

  // Utilitaires
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Vérifie si l'email est vérifié
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
}