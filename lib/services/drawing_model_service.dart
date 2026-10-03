// Sends a spiral drawing to the hosted drawing model and parses its
// Parkinson's prediction.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Holds one drawing model prediction, parsed from the API's JSON response.
class DrawingPredictionResult {
  final String prediction;
  final double parkinsonProbability;
  final double threshold;

  const DrawingPredictionResult({
    required this.prediction,
    required this.parkinsonProbability,
    required this.threshold,
  });

  factory DrawingPredictionResult.fromJson(Map<String, dynamic> json) {
    return DrawingPredictionResult(
      prediction: json['prediction'] as String,
      parkinsonProbability: (json['parkinson_probability'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
    );
  }

  /// 1 if the model predicted Parkinson's, 0 otherwise — matches the
  /// `predictionCode` convention the voice model (and Firestore) already
  /// use, so both modalities store/display the same way.
  int get predictionCode =>
      prediction.toLowerCase().contains('parkinson') ? 1 : 0;

  Map<String, dynamic> toFirestoreMap() => {
        'prediction': prediction,
        'predictionCode': predictionCode,
        'probabilityPd': parkinsonProbability,
      };
}

/// Talks to the NeuroInsight-PD spiral-drawing model, hosted separately on
/// Render — the same model the companion web portal uses. It takes the raw
/// drawing image itself (png/jpg/jpeg), not pre-computed features.
class DrawingModelService {
  DrawingModelService._();
  static final DrawingModelService instance = DrawingModelService._();

  static const _baseUrl = 'https://drawing-backend-iz1o.onrender.com';

  // Uploads the drawing image as multipart form data and returns the
  // parsed prediction. Throws if the request times out or the API errors.
  Future<DrawingPredictionResult> predict({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

    late final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
    } on TimeoutException {
      throw Exception(
        'The model took too long to respond. Free-tier hosting can take '
        'up to a minute to wake up — please try again.',
      );
    }
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Model API returned ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DrawingPredictionResult.fromJson(data);
  }
}
