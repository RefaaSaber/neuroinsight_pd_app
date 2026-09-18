/// Simple in-memory user/patient model. In a real app this would come from
/// the backend after login; here it is mock data for the frontend demo.
class UserModel {
  final String fullName;
  final String displayName;
  final String role;
  final String nationalId;
  final String dateOfBirth;
  final String hospitalFileNo;
  String email;
  String phoneNumber;

  UserModel({
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

  static UserModel mock() {
    return UserModel(
      fullName: 'Sara Mohammed Al-Harbi',
      displayName: 'Sara Al-Harbi',
      role: 'Patient',
      nationalId: '1098765432',
      dateOfBirth: '15 / 03 / 1962',
      hospitalFileNo: 'KAU-2026-003841',
      email: 'SaraAl-Harbi@gmail.com',
      phoneNumber: '966+ 55 904 3628',
    );
  }
}