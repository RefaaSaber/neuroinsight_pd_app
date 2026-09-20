import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

/// My Profile — editable email/phone (saved to Firestore) and Sign Out.
class ProfileTab extends StatefulWidget {
  final UserModel user;
  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final userId = widget.user.id;
    if (userId == null) return;

    setState(() => _saving = true);

    await DbHelper.instance.updateContact(
      userId: userId,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    widget.user.email = _emailController.text;
    widget.user.phoneNumber = _phoneController.text;

    if (!mounted) return;
    setState(() => _saving = false);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Changes saved Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    DbHelper.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(child: Text('🧠', style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(height: 10),
              Text(user.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text(user.role, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    _readOnlyField('Full Name', user.fullName),
                    _readOnlyField('National ID', user.nationalId),
                    _readOnlyField('Date of Birth', user.dateOfBirth),
                    _readOnlyField('Hospital File No.', user.hospitalFileNo),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Editable Information', style: TextStyle(fontWeight: FontWeight.w700)),
                    const Text('You can update your contact details below.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(controller: _emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone Number')),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _saveChanges, child: const Text('Save Changes'))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmSignOut,
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (_saving)
          Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
      ],
    );
  }
}