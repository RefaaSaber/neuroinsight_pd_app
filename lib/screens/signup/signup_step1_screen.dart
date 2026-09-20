import 'package:flutter/material.dart';
import '../../models/signup_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/signup_header.dart';
import 'signup_step2_screen.dart';

/// Frame 3 — Sign Up Step 1 of 3: Personal Information.
class SignUpStep1Screen extends StatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_fullNameController.text.trim().isEmpty ||
        _nationalIdController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please fill in all fields.');
      return;
    }
    setState(() => _errorText = null);

    final data = SignupData(
      fullName: _fullNameController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SignUpStep2Screen(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SignUpHeader(step: 1, onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Enter your details to create your account.', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _fullNameController, decoration: const InputDecoration(hintText: 'Enter your full name')),
                    const SizedBox(height: 16),
                    const Text('National ID', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _nationalIdController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Enter your National ID')),
                    const SizedBox(height: 16),
                    const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Enter your email address')),
                    const SizedBox(height: 16),
                    const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+966 5XX XXX XXXX')),
                    const SizedBox(height: 16),
                    const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(hintText: 'DD / MM / YYYY', suffixIcon: Icon(Icons.calendar_today_outlined)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1990, 1, 1),
                          firstDate: DateTime(1930),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _dobController.text =
                              '${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}';
                        }
                      },
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(onPressed: _continue, child: const Text('Continue')),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Log In'),
                        ),
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