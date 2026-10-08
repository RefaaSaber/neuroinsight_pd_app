import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

// Uploads a spiral-drawing photo to Cloudinary so there's a URL the doctor
// can open on the website to see the actual image, not just the AI's
// prediction.

/// Uploads a file to Cloudinary using an unsigned upload preset, so no
/// secret key is needed in the app's code.
class CloudinaryUploadService {
  CloudinaryUploadService._();

  static final CloudinaryUploadService instance = CloudinaryUploadService._();

  // From the NeuroInsight-PD Cloudinary account's Dashboard (Cloud name)
  // and Settings → Upload → Upload presets (an unsigned preset).
  static const String _cloudName = 'fx91bxgx';
  static const String _uploadPreset = 'storge';

  /// Uploads [bytes] and returns the public URL Cloudinary gives back.
  /// Throws an [Exception] with a short message if it fails.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Image upload failed (${response.statusCode}). Please try again.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String?;
    if (url == null) {
      throw Exception('Image upload did not return a usable URL.');
    }
    return url;
  }
}
