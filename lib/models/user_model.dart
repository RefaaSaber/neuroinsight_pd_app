/// A signed-in patient's account, backed by Firebase Authentication +
/// Firestore (see lib/services/db_helper.dart).
class UserModel {
  final String? id;
  final String fullName;
  final String displayName;
  final String role;
  final String nationalId;
  final String dateOfBirth;
  final String hospitalFileNo;
  String email;
  String phoneNumber;

  UserModel({
    this.id,
    required this.fullName,
    required this.displayName,
    required this.role,
    required this.nationalId,
    required this.dateOfBirth,
    required this.hospitalFileNo,
    this.email = '',
    this.phoneNumber = '',
  });

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}