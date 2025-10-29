// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  User? currentUser() => _auth.currentUser;

  Future<Map<String, dynamic>?> fetchProfile() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final doc = await _db.collection('users').doc(u.uid).get();
    return doc.exists ? doc.data() : null;
  }
}
