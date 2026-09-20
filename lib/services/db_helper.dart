import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';

/// Real, cloud-backed persistence via Firebase Authentication + Cloud
/// Firestore. Any client (this app, or the companion website) connected to
/// the same Firebase project sees the same accounts and data.
class DbHelper {
  DbHelper._();
  static final DbHelper instance = DbHelper._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel?> createUser({
    required String fullName,
    required String nationalId,
    required String email,
    required String phone,
    required String dateOfBirth,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final hospitalFileNo = 'KAU-${DateTime.now().year}-${(1000 + nationalId.hashCode.abs() % 9000)}';

      await _db.collection('users').doc(uid).set({
        'fullName': fullName,
        'nationalId': nationalId,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'hospitalFileNo': hospitalFileNo,
      });

      return UserModel(
        id: uid,
        fullName: fullName,
        displayName: fullName,
        role: 'Patient',
        nationalId: nationalId,
        dateOfBirth: dateOfBirth,
        hospitalFileNo: hospitalFileNo,
        email: email,
        phoneNumber: phone,
      );
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<UserModel?> login({required String nationalId, required String password}) async {
    try {
      final query = await _db.collection('users').where('nationalId', isEqualTo: nationalId).limit(1).get();
      if (query.docs.isEmpty) return null;

      final data = query.docs.first.data();
      final email = data['email'] as String?;
      if (email == null || email.isEmpty) return null;

      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;

      return UserModel(
        id: uid,
        fullName: data['fullName'] ?? '',
        displayName: data['fullName'] ?? '',
        role: 'Patient',
        nationalId: data['nationalId'] ?? '',
        dateOfBirth: data['dateOfBirth'] ?? '',
        hospitalFileNo: data['hospitalFileNo'] ?? '',
        email: data['email'] ?? '',
        phoneNumber: data['phone'] ?? '',
      );
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  Future<void> updateContact({required String userId, required String email, required String phone}) async {
    await _db.collection('users').doc(userId).update({'email': email, 'phone': phone});
  }

  Future<List<RecentTestModel>> getTests(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('tests')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) {
      final data = d.data();
      return RecentTestModel(
        title: data['title'] as String,
        date: data['date'] as String,
        type: (data['type'] as String) == 'voice' ? TestType.voice : TestType.drawing,
      );
    }).toList();
  }

  Future<void> addTest({
    required String userId,
    required String title,
    required String date,
    required TestType type,
  }) async {
    await _db.collection('users').doc(userId).collection('tests').add({
      'title': title,
      'date': date,
      'type': type == TestType.voice ? 'voice' : 'drawing',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}