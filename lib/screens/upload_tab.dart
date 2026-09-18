import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'upload_success_screen.dart';

/// Frames 7 & 8 — Upload Tests, with a Voice / Drawing segmented toggle.
/// Lets the user pick a real audio file and a real photo from their device.
class UploadTab extends StatefulWidget {
  final UserModel user;
  const UploadTab({super.key, required this.user});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  TestType _selected = TestType.voice;
  bool _isRecording = false;

  String? _audioFileName;
  Uint8List? _drawingBytes;

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _audioFileName = result.files.single.name);
    }
  }

  Future<void> _pickDrawingImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Library'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _drawingBytes = bytes);
    }
  }

  void _submit() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UploadSuccessScreen(testType: _selected)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('Upload Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentButton(
                    label: 'Voice',
                    icon: Icons.mic_none_outlined,
                    selected: _selected == TestType.voice,
                    onTap: () => setState(() => _selected = TestType.voice),
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'Drawing',
                    icon: Icons.edit_outlined,
                    selected: _selected == TestType.drawing,
                    onTap: () => setState(() => _selected = TestType.drawing),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_selected == TestType.voice) _buildVoiceCard() else _buildDrawingCard(),
          const SizedBox(height: 24),
          const Text('Recent Tests', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...RecentTestModel.mockList().map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: cardDecoration(),
                  child: Row(
                    children: [
                      Icon(t.type == TestType.voice ? Icons.mic_none_outlined : Icons.edit_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(t.date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _submit, child: const Text('Upload New Test')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildVoiceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Voice Recording', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Record your voice or upload an audio file', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => _isRecording = !_isRecording),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _isRecording ? AppColors.danger : AppColors.danger.withOpacity(0.85),
                shape: BoxShape.circle,
              ),
              child: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 10),
          Text(_isRecording ? 'Recording… tap to stop' : 'Tap to Record', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('or upload file', style: TextStyle(fontSize: 11, color: AppColors.textSecondary))), Expanded(child: Divider())]),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickAudioFile,
            icon: const Icon(Icons.file_upload_outlined),
            label: const Text('Choose audio file (.mp3 / .wav)'),
          ),
          if (_audioFileName != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: AppColors.chipViewedBg, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.audiotrack, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_audioFileName!, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _audioFileName = null),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Upload Drawing Image', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Draw on paper and take a clear photo', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _pickDrawingImage,
            borderRadius: BorderRadius.circular(12),
            child: _drawingBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Image.memory(_drawingBytes!, width: double.infinity, height: 180, fit: BoxFit.cover),
                        Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Tap to change', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.chipNewBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.image_outlined, color: AppColors.primary, size: 32),
                        SizedBox(height: 8),
                        Text('Tap to upload spiral image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}