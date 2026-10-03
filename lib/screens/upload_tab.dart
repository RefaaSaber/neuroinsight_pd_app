import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/db_helper.dart';
import '../services/drawing_model_service.dart';
import '../services/voice_model_service.dart';
import '../theme/app_theme.dart';
import 'upload_success_screen.dart';

/// Frame 7 — Upload Tests. Voice tests are submitted as a CSV file of
/// pre-extracted acoustic features (matching the NeuroInsight-PD voice
/// model's expected columns) and sent to the model for a real prediction.
/// Drawing tests are submitted as a photo, sent to the drawing model for a
/// real prediction the same way.
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
  String _savingMessage = 'Uploading...';

  // Lets the user pick a CSV file, parses its features, and runs the voice prediction.
  Future<void> _pickVoiceFile() async {
    if (_picking) return;
    _picking = true;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        _showError('Could not read that file. Please try again.');
        return;
      }

      final features = _parseFeaturesFromCsv(String.fromCharCodes(bytes));
      if (features == null) return;

      await _runVoicePrediction(fileName: file.name, features: features);
    } catch (e) {
      _showError('Could not open the file picker. Please try again.');
    } finally {
      _picking = false;
    }
  }

  // Reads the first data row of the CSV into the feature values the voice
  // model expects. Returns null and shows an error if columns are missing.
  Map<String, double>? _parseFeaturesFromCsv(String content) {
    final rows = const CsvToListConverter(eol: '\n').convert(content);
    if (rows.length < 2) {
      _showError('That CSV file needs a header row and at least one data row.');
      return null;
    }

    final header = rows.first.map((h) => h.toString().trim()).toList();
    final dataRow = rows[1];

    final missing = <String>[];
    final features = <String, double>{};

    for (final name in voiceModelFeatureNames) {
      final colIndex = header.indexOf(name);
      if (colIndex == -1 || colIndex >= dataRow.length) {
        missing.add(name);
        continue;
      }
      final raw = dataRow[colIndex];
      final value = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
      if (value == null) {
        missing.add(name);
        continue;
      }
      features[name] = value;
    }

    if (missing.isNotEmpty) {
      _showError('CSV is missing ${missing.length} required column(s), e.g. "${missing.first}".');
      return null;
    }

    return features;
  }

  // Sends the voice features to the model, saves the result, and shows
  // the success screen.
  Future<void> _runVoicePrediction({required String fileName, required Map<String, double> features}) async {
    final userId = widget.user.id;
    if (userId == null) return;

    setState(() {
      _saving = true;
      _savingMessage = 'Analyzing voice data...';
    });

    try {
      final prediction = await VoiceModelService.instance.predict(features);

      final date = DateFormat('MMM d, yyyy').format(DateTime.now());
      await DbHelper.instance.addTest(
        userId: userId,
        title: fileName,
        date: date,
        type: TestType.voice,
        predictionResult: prediction.toFirestoreMap(),
      );

      if (!mounted) return;
      setState(() => _saving = false);

      // The raw AI prediction is saved for the doctor to review on the
      // website — the patient just sees the normal "submitted, pending
      // doctor review" confirmation, not the prediction itself.
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UploadSuccessScreen(testType: TestType.voice)),
      );

      if (!mounted) return;
      widget.onTestUploaded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // Lets the user pick a photo of a drawing and runs the drawing prediction.
  Future<void> _pickDrawingImage() async {
    if (_picking) return;
    _picking = true;
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      await _runDrawingPrediction(fileName: image.name, bytes: bytes);
    } catch (e) {
      _showError('Could not open the photo picker. Please try again.');
    } finally {
      _picking = false;
    }
  }

  // Sends the drawing image to the model, saves the result, and shows
  // the success screen.
  Future<void> _runDrawingPrediction({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final userId = widget.user.id;
    if (userId == null) return;

    setState(() {
      _saving = true;
      _savingMessage = 'Analyzing drawing...';
    });

    try {
      final prediction = await DrawingModelService.instance.predict(
        bytes: bytes,
        filename: fileName,
      );

      final date = DateFormat('MMM d, yyyy').format(DateTime.now());
      await DbHelper.instance.addTest(
        userId: userId,
        title: fileName,
        date: date,
        type: TestType.drawing,
        predictionResult: prediction.toFirestoreMap(),
      );

      if (!mounted) return;
      setState(() => _saving = false);

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UploadSuccessScreen(testType: TestType.drawing)),
      );

      if (!mounted) return;
      widget.onTestUploaded?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              const Text('Upload voice data or a drawing test.', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              _UploadCard(
                icon: Icons.mic_none_outlined,
                title: 'Voice Test',
                subtitle: 'Upload a CSV of voice feature data — sent to the model for a real result',
                buttonLabel: 'Choose CSV File',
                onTap: _saving ? null : _pickVoiceFile,
              ),
              const SizedBox(height: 16),
              _UploadCard(
                icon: Icons.edit_outlined,
                title: 'Drawing Test',
                subtitle: 'Upload a photo of a spiral drawing — sent to the model for a real result',
                buttonLabel: 'Choose Photo',
                onTap: _saving ? null : _pickDrawingImage,
              ),
            ],
          ),
        ),
        if (_saving)
          Container(
            color: Colors.black26,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: cardDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(_savingMessage, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A card describing one test type (voice or drawing) with an upload button.
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
