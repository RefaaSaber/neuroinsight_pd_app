import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../theme/app_theme.dart';
import 'upload_success_screen.dart';

/// Frame 7 — Upload Tests. Lets the user pick a real audio file (voice
/// test) or a real photo/drawing (drawing test) from their device, then
/// saves a test record to Firestore under the signed-in user.
class UploadTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback? onTestUploaded;

  const UploadTab({super.key, required this.user, this.onTestUploaded});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  bool _saving = false;
  bool _picking = false;

  Future<void> _pickVoiceFile() async {
    if (_picking) return;
    _picking = true;
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) return;
      final fileName = result.files.first.name;
      await _saveTest(title: fileName, type: TestType.voice);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the file picker. Please try again.')),
      );
    } finally {
      _picking = false;
    }
  }

  Future<void> _pickDrawingImage() async {
    if (_picking) return;
    _picking = true;
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await _saveTest(title: image.name, type: TestType.drawing);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the photo picker. Please try again.')),
      );
    } finally {
      _picking = false;
    }
  }

  Future<void> _saveTest({required String title, required TestType type}) async {
    final userId = widget.user.id;
    if (userId == null) return;

    setState(() => _saving = true);

    final date = DateFormat('MMM d, yyyy').format(DateTime.now());
    await DbHelper.instance.addTest(userId: userId, title: title, date: date, type: type);

    if (!mounted) return;
    setState(() => _saving = false);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UploadSuccessScreen(testType: type)),
    );

    if (!mounted) return;
    widget.onTestUploaded?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Upload a voice recording or a drawing test.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _UploadCard(
                icon: Icons.mic_none_outlined,
                title: 'Voice Test',
                subtitle: 'Upload an audio recording (mp3, wav, m4a)',
                buttonLabel: 'Choose Audio File',
                onTap: _saving ? null : _pickVoiceFile,
              ),
              const SizedBox(height: 16),
              _UploadCard(
                icon: Icons.edit_outlined,
                title: 'Drawing Test',
                subtitle: 'Upload a photo of a spiral drawing',
                buttonLabel: 'Choose Photo',
                onTap: _saving ? null : _pickDrawingImage,
              ),
            ],
          ),
        ),
        if (_saving)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;

  const _UploadCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: AppColors.chipNewBg, child: Icon(icon, color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.upload_outlined),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}