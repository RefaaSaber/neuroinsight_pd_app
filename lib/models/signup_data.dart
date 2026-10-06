/// Carries the fields collected across Sign Up steps 1-3, before the
/// account is actually created in Firebase on the final step.
class SignupData {
  String firstName;
  String lastName;
  String fullName;
  String nationalId;
  String email;
  String phone;
  String dateOfBirth;

  SignupData({
    this.firstName = '',
    this.lastName = '',
    this.fullName = '',
    this.nationalId = '',
    this.email = '',
    this.phone = '',
    this.dateOfBirth = '',
  });
}
