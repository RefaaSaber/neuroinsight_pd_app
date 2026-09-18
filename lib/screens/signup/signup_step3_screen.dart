import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/signup_header.dart';
import '../main_shell.dart';

/// Frame 5 — Sign Up Step 3 of 3: Set Your Password.
/// Requires 8+ characters (16+ recommended) mixing uppercase, lowercase,
/// a number, and a special character. Create Account is blocked otherwise.
class SignUpStep3Screen extends StatefulWidget {
  const SignUpStep3Screen({super.key});

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _errorText;

  String get _password => _passwordController.text;

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasRecommendedLength => _password.length >= 16;
  bool get _hasUppercase => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _password.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => _password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
  bool get _passwordsMatch => _password.isNotEmpty && _password == _confirmController.text;
  bool get _canSubmit => _isPasswordValid && _passwordsMatch;

  double get _strength {
    var score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase && _hasLowercase) score++;
    if (_hasNumber) score++;
    if (_hasSpecialChar) score++;
    if (_hasRecommendedLength) score++;
    return score / 5;
  }

  String get _strengthLabel {
    if (_strength >= 1) return 'Strong';
    if (_strength >= 0.6) return 'Medium';
    if (_strength > 0) return 'Weak';
    return '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _createAccount() {
    setState(() {
      if (!_isPasswordValid) {
        _errorText = 'Use 8+ characters with upper/lowercase letters, a number, and a special character.';
      } else if (!_passwordsMatch) {
        _errorText = 'Passwords do not match.';
      } else {
        _errorText = null;
      }
    });

    if (!_canSubmit) return;

    // TODO: send the collected sign-up data (including this password) to
    // the backend, then log the user in and land on the main app shell.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Widget _requirementRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(met ? Icons.check_circle : Icons.cancel, size: 16, color: met ? AppColors.success : AppColors.danger),
          const SizedBox(width: 6),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SignUpHeader(step: 3, onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create a Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Choose a strong password to protect your account.', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    const Text('New Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      onChanged: (_) => setState(() => _errorText = null),
                      decoration: const InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmController,
                      obscureText: true,
                      onChanged: (_) => setState(() => _errorText = null),
                      decoration: const InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Password Strength', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          _strengthLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: _strength >= 1 ? AppColors.success : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _strength,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: _strength >= 1 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _requirementRow('At least 8 characters (16+ recommended)', _hasMinLength),
                    _requirementRow('Uppercase and lowercase letters', _hasUppercase && _hasLowercase),
                    _requirementRow('At least one number', _hasNumber),
                    _requirementRow('At least one special character (e.g. @, #)', _hasSpecialChar),
                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_errorText!, style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: _createAccount, child: const Text('Create Account')),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.chipViewedBg, borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Text('🎉', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You're almost there! Complete setup to start monitoring your health.",
                              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: AppColors.textSecondary),
                        SizedBox(width: 6),
                        Text('Your data is encrypted & secure', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}