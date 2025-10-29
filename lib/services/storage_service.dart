import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data to Firestore
  static Future<void> saveUserData(
    String uid,
    String name,
    String email,
    String year,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'year': year,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ User data saved successfully for $uid');
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  // Optional: Fetch user data
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data();
      } else {
        print('⚠️ No user found for $uid');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
      return null;
    }
  }
}
