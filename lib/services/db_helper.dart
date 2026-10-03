// Database helper: all reads and writes to Firebase Auth / Firestore go
// through this one class.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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

  // Creates the Firebase Auth account and the matching Firestore user
  // document (always saved with role 'patient'). Returns null on failure.
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
        // Lets the doctor/radiologist web portal tell patient accounts apart
        // from clinical staff accounts, which get 'doctor' / 'radiologist'
        // here instead. Patients made before this field existed are treated
        // as patients too (see the web repository's handling of a missing
        // role).
        'role': 'patient',
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

  // Looks up the account by national ID to find its email, then signs in
  // with Firebase Auth using that email and the given password.
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

  // Signs the current user out of Firebase Auth.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sends Firebase's password-reset email. Returns false if it fails.
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // Updates the user's saved email and phone number.
  Future<void> updateContact({required String userId, required String email, required String phone}) async {
    await _db.collection('users').doc(userId).update({'email': email, 'phone': phone});
  }

  // Fetches this user's test history, newest first.
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

  /// Saves a test record. When [predictionResult] is given (voice and
  /// drawing tests both have live models now), it's stored alongside the
  /// test so the Reports tab — and the doctor's website — can show a real
  /// result.
  Future<void> addTest({
    required String userId,
    required String title,
    required String date,
    required TestType type,
    Map<String, dynamic>? predictionResult,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'date': date,
      'type': type == TestType.voice ? 'voice' : 'drawing',
      'createdAt': FieldValue.serverTimestamp(),
      // 'pending_review' once an AI prediction exists for the doctor's
      // website to pick up; 'uploaded' otherwise (e.g. an MRI test, which
      // has no model yet). The doctor's website updates this to 'reviewed'
      // once a report has been written for this test.
      'status': predictionResult != null ? 'pending_review' : 'uploaded',
    };
    if (predictionResult != null) {
      data['prediction'] = predictionResult;
    }
    await _db.collection('users').doc(userId).collection('tests').add(data);
  }

  /// Diagnostic reports a doctor has submitted (on the web portal) —
  /// each one covers one or more of this patient's tests — newest first.
  /// A saved-but-not-submitted draft doesn't appear here yet — only once
  /// the doctor submits it.
  Future<List<ReportModel>> getReports(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('reports')
        .orderBy('writtenAt', descending: true)
        .get();

    final reports = <ReportModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['status'] != 'submitted') continue;

      final writtenAt = data['writtenAt'];
      final writtenDate = writtenAt is Timestamp
          ? DateFormat('MMM d, yyyy').format(writtenAt.toDate())
          : '';

      reports.add(ReportModel(
        id: doc.id,
        testIds: List<String>.from(data['testIds'] as List? ?? const []),
        testTypeLabels:
            List<String>.from(data['testTypeLabels'] as List? ?? const []),
        title: data['title'] as String? ?? 'Report',
        doctorName: data['doctorName'] as String? ?? 'Doctor',
        status: (data['reportViewed'] as bool? ?? false) ? ReportStatus.viewed : ReportStatus.new_,
        clinicalNotes: data['clinicalNotes'] as String? ?? '',
        recommendations: data['recommendations'] as String? ?? '',
        reportWrittenDate: writtenDate,
      ));
    }
    return reports;
  }

  /// Marks a report as read once the patient opens it, so it stops showing
  /// as "new" in the Reports tab.
  Future<void> markReportViewed(String userId, String reportId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('reports')
        .doc(reportId)
        .update({'reportViewed': true});
  }
}
