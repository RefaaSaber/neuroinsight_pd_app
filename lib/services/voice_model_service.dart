// Sends pre-computed acoustic features to the hosted voice model and
// parses its Parkinson's prediction.
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// The 43 acoustic feature names the NeuroInsight-PD voice model expects,
/// in the exact order documented by the model's own /schema endpoint at
/// https://neuroinsight-voicemodel.onrender.com/schema
const List<String> voiceModelFeatureNames = [
  'Jitter_rel', 'Jitter_abs', 'Jitter_RAP', 'Jitter_PPQ',
  'Shim_loc', 'Shim_dB', 'Shim_APQ3', 'Shim_APQ5', 'Shi_APQ11',
  'HNR05', 'HNR15', 'HNR25', 'HNR35', 'HNR38',
  'RPDE', 'DFA', 'PPE', 'GNE',
  'MFCC0', 'MFCC1', 'MFCC2', 'MFCC3', 'MFCC4', 'MFCC5', 'MFCC6',
  'MFCC7', 'MFCC8', 'MFCC9', 'MFCC10', 'MFCC11', 'MFCC12',
  'Delta0', 'Delta1', 'Delta2', 'Delta3', 'Delta4', 'Delta5', 'Delta6',
  'Delta7', 'Delta8', 'Delta9', 'Delta10', 'Delta11', 'Delta12',
];

/// Holds one voice model prediction, parsed from the API's JSON response.
class VoicePredictionResult {
  final String prediction;
  final int predictionCode;
  final double probabilityPd;

  const VoicePredictionResult({
    required this.prediction,
    required this.predictionCode,
    required this.probabilityPd,
  });

  factory VoicePredictionResult.fromJson(Map<String, dynamic> json) {
    return VoicePredictionResult(
      prediction: json['prediction'] as String,
      predictionCode: json['prediction_code'] as int,
      probabilityPd: (json['probability_pd'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
        'prediction': prediction,
        'predictionCode': predictionCode,
        'probabilityPd': probabilityPd,
      };
}

/// Talks to the NeuroInsight-PD voice model, hosted separately on Render.
/// It expects 43 pre-computed acoustic features (not a raw audio file) —
/// see voiceModelFeatureNames above for the exact names and order.
class VoiceModelService {
  VoiceModelService._();
  static final VoiceModelService instance = VoiceModelService._();

  static const _baseUrl = 'https://neuroinsight-voicemodel.onrender.com';

  // Posts the feature map as JSON and returns the parsed prediction.
  // Throws if the request times out or the API errors.
  Future<VoicePredictionResult> predict(Map<String, double> features) async {
    final uri = Uri.parse('$_baseUrl/predict');

    late final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'features': features}),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw Exception(
          'The model took too long to respond. Free-tier hosting can take up to a minute to wake up — please try again.');
    }

    if (response.statusCode != 200) {
      throw Exception('Model API returned ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return VoicePredictionResult.fromJson(data);
  }
}
