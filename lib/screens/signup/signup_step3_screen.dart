import 'package:flutter/material.dart';
import '../../models/signup_data.dart';
import '../../services/db_helper.dart';
import '../../theme/app_theme.dart';
import '../main_shell.dart';

/// Sign Up Step 3 of 3 — Create Password.
/// This is where the account is actually created in Firebase.
class SignUpStep3Screen extends StatefulWidget {
  final SignupData data;
  const SignUpStep3Screen({super.key, required this.data});

  @override
  State<SignUpStep3Screen> createState() => _SignUpStep3ScreenState();
}

class _SignUpStep3ScreenState extends State<SignUpStep3Screen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _password => _passwordController.text;

  bool get _hasMinLength => _password.length >= 8;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_password);
  bool get _hasLower => RegExp(r'[a-z]').hasMatch(_password);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_password);
  bool get _hasSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(_password);

  bool get _isPasswordValid =>
      _hasMinLength && _hasUpper && _hasLower && _hasNumber && _hasSpecial;

  Widget _rule(String text, bool met) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: met ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: met ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Future<void> _createAccount() async {
    setState(() => _errorText = null);

    if (!_isPasswordValid) {
      setState(() => _errorText = 'Please meet all password requirements.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorText = 'Passwords do not match.');
      return;
    }

    setState(() => _loading = true);

    final user = await DbHelper.instance.createUser(
      fullName: widget.data.fullName,
      nationalId: widget.data.nationalId,
      email: widget.data.email,
      phone: widget.data.phone,
      dateOfBirth: widget.data.dateOfBirth,
      password: _password,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      setState(() => _errorText =
          'That email is already registered. Try logging in instead.');
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(user: user)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 3 of 3', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              const Text('Create a Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Choose a strong password to secure your account.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscure1,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmController,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password must contain:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    _rule('At least 8 characters', _hasMinLength),
                    const SizedBox(height: 6),
                    _rule('An uppercase letter', _hasUpper),
                    const SizedBox(height: 6),
                    _rule('A lowercase letter', _hasLower),
                    const SizedBox(height: 6),
                    _rule('A number', _hasNumber),
                    const SizedBox(height: 6),
                    _rule('A special character', _hasSpecial),
                  ],
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createAccount,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}